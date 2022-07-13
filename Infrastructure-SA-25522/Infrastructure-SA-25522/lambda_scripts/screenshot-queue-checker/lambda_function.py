import time
import boto3
import os
import datetime as dt
from datadog import initialize, api


region_code = os.environ["AWS_REGION"]
ssm = boto3.client('ssm', region_name=region_code)
cw = boto3.client("cloudwatch", region_name=region_code)
DD_HOST = "https://api.datadoghq.com/api/v1/query"
DD_QUERY = "avg:custom.screenshot_queue_length_splash{region:us-east-1}"
DD_API_KEY = ssm.get_parameter(
    Name="/default/production/screenshot-queue/DD_API_KEY",
    WithDecryption=True
)["Parameter"]["Value"]
DD_APPLICATION_KEY = ssm.get_parameter(
    Name="/default/production/screenshot-queue/DD_APPLICATION_KEY",
    WithDecryption=True
)["Parameter"]["Value"]
     
## fetching data from datadog ##
def datadog_metric(startTime, endTime):
    options = {
        "api_key": DD_API_KEY,
        "app_key": DD_APPLICATION_KEY,
    }
    initialize(**options)

    return api.Metric.query(start=startTime, end=endTime, query=DD_QUERY)

## publishing data to cloudwatch
def publish_data_to_cw_metric(avgValue):
    return cw.put_metric_data(
        Namespace="SCREENSHOTQUEUE",
        MetricData=[
            {
                "MetricName": "ScreenshotQueueLength",
                "Dimensions": [{"Name": "QUEUE_SERVICE", "Value": "QueueLength"}],
                "Value": float(avgValue),
            }
        ],
    )

def lambda_handler(event, context):
    startTime = int(time.time()) - 60
    endTime = int(time.time())
    print(
        "startTime: {}\nendTime: {}".format(
            dt.datetime.utcfromtimestamp(startTime).replace(tzinfo=dt.timezone.utc),
            dt.datetime.utcfromtimestamp(endTime).replace(tzinfo=dt.timezone.utc),
        )
    )
    print("*** Data dog query ***")
    ddResponse = datadog_metric(startTime, endTime)
    print(f"Datadog response: {ddResponse}")
    seriesPointlist = ddResponse["series"][0]["pointlist"]
    print("*** Print pointlist ***")
    print(f"pointlist: {seriesPointlist}")
    pointlistData = [x[1] for x in seriesPointlist]
    print(f"*** pointlistData: {pointlistData} ***")
    avgData = sum(pointlistData) / len(pointlistData)
    print(f"avg value: {avgData}")
    cwMetricResponse = publish_data_to_cw_metric(avgData)
    print(f"*** CW Metric Response: {cwMetricResponse} ***")

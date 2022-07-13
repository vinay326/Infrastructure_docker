function in_iframe () {
    try {
        return window.self !== window.top;
    } catch (e) {
        return true;
    }
}

if (in_iframe()) {
    var body = document.body;
    body.classList.add("iframe_embedded");
}

function getParameterByName(name, url = window.location.href) {
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

window.addEventListener('load', function(event) {
    var runparent = getParameterByName('runparent');
    var pathname = window.location.pathname;

    if (parseInt(runparent) === 1 && pathname.includes('/logout')) {
        window.addEventListener('unload', function(event) {
            window.parent.postMessage("logout", "*");
        }, {once: true});
    }
}, {once: true}); 

window.addEventListener('message', function(e) {
    var data = e.data;
    if (data === 'iframe_url') {
        var location = window.location.href;
        window.parent.postMessage(location, "*");
    } else {
        window.parent.postMessage(data, "*");
    }
}, false);

var error_interval = setInterval(function() {
    var titles = document.getElementsByClassName("euiTitle");
    for(var i = 0; i < titles.length; i++) {
        if (titles[i].innerHTML === 'Something went wrong') {
            window.parent.postMessage("logout", "*");
            clearInterval(error_interval);
        }
    }
}, 500);

setTimeout(function() {
    clearInterval(error_interval);
}, 15000);

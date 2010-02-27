import Qt 4.6

Item {
    property string status: "Connecting to Facebook..."
    property url url //: "http://www.facebook.com/login.php?api_key=9933e2bc397abe5bd5c9de2d0addfa32&connect_display=popup&v=1.0&next=http://www.facebook.com/connect/login_success.html&cancel_url=http://www.facebook.com/connect/login_failure.html&fbconnect=true&return_session=true&req_perms=read_stream,publish_stream,offline_access"
    property string session_key
    property string session_secret
    signal connected

    anchors.fill: parent

    WebView {
        anchors.fill: parent
        url: parent.url
        onUrlChanged: {
            var u = String(url)
console.log("URL=",u)
            if (u == "http://www.facebook.com/connect/login_failure.html") {
                parent.status="Cannot Login to Facebook"
                opacity=0
            } else {
                var q = u.indexOf('?')
                if (u.substring(q-12,q-5) == "success") {
                    var _params=u.substring(q+1).split("&")
                    for (var i=0; i<_params.length; ++i) {
                        var _kv = _params[i].split('=')
console.log("param=",_kv);
                        if (_kv[0] == "session") {
                            var session = JSON.parse(_kv[1])
                            parent.status=""
                            session_key = session.session_key
                            session_secret = session.secret
                            connected()
                            opacity=0
                            break;
                        }
                    }
                }
            }
        }
    }
}

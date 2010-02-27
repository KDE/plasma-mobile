/*
    Creates a FB.Facebook.ApiClient object, providing a subset of the
    Facebook JavaScript API as documented at:

    http://developers.facebook.com/docs/?u=facebook.jslib.FB.ApiClient

    Currently provides:

    friends_get(flid)
    users_getInfo(uids,fields)
    get_apiKey()

    Others can be trivially added as-needed.
*/
function facebook(parent, api_key, req_perms)
{
    var listparam = function(l)
        {
            var r
            if (l[0])
                r = l[0]
            for (var i=1; i<l.length; ++i) {
                r += ","
                r += l[i]
            }
            return r;
        };

    if (!req_perms)
        req_perms = "read_stream,publish_stream,offline_access";

    var session_key;
    var session_secret;
    var queue = [];
    var loginComponent = createComponent("FacebookLogin.qml");
    var database = openDatabaseSync("QML Facebook "+api_key, "", "Cache for offline Facebook data", 1000,
            function(db)
            {
                db.changeVersion("","1.0")
                db.transaction(function(tx){
                    tx.executeSql('CREATE TABLE Secret(session_secret TEXT, session_key TEXT)');
                })
            });
    var process_queue = function()
            {
                if (!queue.length || !session_key)
                    return

                var task = queue.shift()

                var args = []
                for (var i=0; i<task.params.length; ++i)
                    args.push(task.params[i])
                args.push("api_key="+api_key)
                args.push("v=1.0")
                var now = new Date()
                args.push("call_id="+Math.floor(now.getTime()/1000))
                args.push("session_key="+session_key)
                args.push("method=facebook."+task.method)
                args.push("format=json")
                args.sort()

                var post=""
                var hashable=""
                for (var i=0; i<args.length; ++i) {
                    post += args[i]+"&"
                    hashable += args[i]
                }
                hashable += session_secret
                post += "sig=" + Qt.md5(hashable)
                console.log("POST:",post)

                task.doc.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
                task.doc.send(post);
            };
    var loginItem;

    var r = {
        "logout": function()
            {
                database.transaction(function(tx){ tx.executeSql('DELETE FROM Secret',[]); });
                session_key = undefined;
            },

        "login": function()
            {
                if (loginComponent.isError) {
                    throw("Error loading FacebookLogin.qml")
                } else if (loginComponent.isLoading) {
                    throw("Still loading FacebookLogin.qml")
                } else {
                    var rs
                    database.transaction(function(tx){ rs = tx.executeSql('SELECT session_secret,session_key FROM Secret') })
                    if (rs.rows.length == 0) {
                        loginItem = loginComponent.createObject()
                        var fb = this
                        loginItem.parent = parent
                        loginItem.connected.connect(function()
                            {
                                session_secret = loginItem.session_secret;
                                session_key = loginItem.session_key; 
                                database.transaction(function(tx){ tx.executeSql('INSERT INTO Secret VALUES(?,?)',[session_secret,session_key]); });
                                process_queue();
                            })
                        loginItem.url = "http://www.facebook.com/login.php?api_key="+
                            api_key+
                            "&connect_display=popup&v=1.0&next=http://www.facebook.com/connect/login_success.html&cancel_url=http://www.facebook.com/connect/login_failure.html&fbconnect=true&return_session=true&req_perms="+
                            req_perms;
                    } else {
                        session_secret = rs.rows.item(0).session_secret
                        session_key = rs.rows.item(0).session_key
                        process_queue();
                    }
                }
            },

        // Facebook JavaScript API

        "callMethod": function(method, params, callback)
            {
                var doc = new XMLHttpRequest();
                doc.open("POST", "http://api.facebook.com/restserver.php");
                doc.onreadystatechange = function() {
                    if (doc.readyState == XMLHttpRequest.DONE) {
                        if (callback)
                            callback(JSON.parse(doc.responseText))
                    } else if (doc.readyState == XMLHttpRequest.ERROR) {
                        throw "JSON parse error"
                    } else
                        return;
                    process_queue()
                }
                var job = new Object
                job.doc = doc
                job.method = method
                job.params = params
                queue.push(job)
                process_queue()
            },

        //auth_getAppPublicKey(String target_app_key,  Object onRequestCompleted)
        //auth_getSignedPublicSessionData(Object onRequestCompleted)
        /*
        connect_getUnconnectedFriendsCount(Object onRequestCompleted)
        Returns the number of friends who have pending accounts on a Connect site.

        events_get(String uid,  Array eids,  Number startTime,  Number endTime,  String rsvpStatus,  Object onRequestCompleted)
        Client side call to events.get.

        events_getMembers(Number eid,  Object onRequestCompleted)
        Client side call to events.getMembers.

        fbml_refreshImgSrc(String url,  Object onRequestCompleted)
        Client side call to fbml.refreshImgSrc.

        fbml_refreshRefUrl(String url,  Object onRequestCompleted)
        Client side call to fbml.refreshRefUrl.

        fbml_setRefHandle(String handle,  String fbml,  Object onRequestCompleted)

        feed_getAppFriendStories(Object onRequestCompleted)
        Return a list of all application stories recently published by the user's friends.

        feed_publishUserAction(Number template_bundle_id,  Object template_data,  Array target_ids,  String body_general,  Number story_size,  String user_message,  Object onRequestCompleted)
        This is a recommended - use FB.Connect.streamPublish instead.

        fql_query(String query,  Object onRequestCompleted)
        Make an FQL query directly from the client.

        friends_areFriends(Array uids1,  Array uids2,  Object onRequestCompleted)

        */

        "friends_get": function(flid,onRequestCompleted) { this.callMethod("friends.get", flid ? ["flid="+flid] : [], onRequestCompleted) },
            // Return a array of friend ids for the currently logged in user.

        /*
        friends_getAppUsers(Object onRequestCompleted)

        friends_getLists(Object onRequestCompleted)

        getSessionFromSigParams(Object sigParams)
        */

        "get_apiKey": function() { return api_key },

        /*
        get_session()
        Get session information for the currently logged in user.

        get_sessionWaitable()
        Retrieves the FB:Waitable for the session object.

        groups_get(String uid,  Array gids,  Object onRequestCompleted)

        groups_getMembers(Number gid,  Object onRequestCompleted)

        intl_uploadNativeStrings(Array native_strings,  Object onRequestCompleted)

        notifications_get(Object onRequestCompleted)

        notifications_send(Array to_ids,  String notification,  Object onRequestCompleted)

        notifications_sendEmail(Array recipients,  String subject,  String text,  String fbml,  Object onRequestCompleted)

        pages_getInfo(Array fields,  Array page_ids,  String uid,  Object onRequestCompleted)
        Client side call to pages.getInfo.

        pages_isAdmin(Number page_id,  Object onRequestCompleted)
        Client side call to pages.isAdmin.

        pages_isAppAdded(Number page_id,  Object onRequestCompleted)
        Client side call to pages.isAppAdded.

        pages_isFan(Number page_id,  String uid,  Object onRequestCompleted)
        Client side call to pages.isFan.

        photos_addTag(String pid,  String tag_uid,  String tag_text,  Number x,  Number y,  Object tags,  Object onRequestCompleted)
        Client side call to photos.addTag.

        photos_createAlbum(String name,  String location,  String description,  Object onRequestCompleted)
        Client side call to photos.createAlbum.

        photos_get(Object subj_id,  Object aid,  Array pids,  Object onRequestCompleted)
        Client side call to photos.get.

        photos_getAlbums(String uid,  Array aids,  Object onRequestCompleted)
        Client side call to photos.getAlbums.

        photos_getTags(Array pids,  Object onRequestCompleted)
        Client side call to photos.getTags.

        preloadFQL_get(Function callback)

        privacy_canSee(Array uids,  Array whats,  Object onRequestCompleted)

        profile_getFBML(String uid,  Object onRequestCompleted)

        profile_setFBML(String uid,  String profile,  String profile_action,  String mobile_profile,  String profile_main,  Object onRequestCompleted)

        requireLogin(Function callback)
        This method is deprecated - use FB.Connect.requireSession instead.

        revokeAuthorization(String uid,  Object onRequestCompleted)

        sessionIsExpired(SessionRecord record)
        Determine if a particular session is expired yet.

        set_session(SessionRecord value)
        Sets the current session information.

        stream_get(Array source_ids,  Number start_time,  Number end_time,  Number limit,  String filter_key,  Object onRequestCompleted)
        Gets the stream on behalf of a user using a set of users.

        stream_getComments(String post_id,  Object onRequestCompleted)
        Gets the full comments given a post_id from stream.get or the stream FQL table.

        stream_getFilters(Object onRequestCompleted)
        Gets the filters (with relevant filter keys for stream.get) for the current user.
        */

        "users_getInfo": function(uids,fields,onRequestCompleted) { this.callMethod("users.getInfo", ["uids="+listparam(uids),"fields="+listparam(fields)], onRequestCompleted); },
            // Client side call to users.getInfo.

        /*
        users_hasAppPermission(String ext_perm,  Object onRequestCompleted)
        Client side call to users.hasAppPermission.

        users_isAppAdded(Object onRequestCompleted)
        Client side call to users.isAppAdded.

        users_isAppUser(Object onRequestCompleted)
        Determine if the user has authorized this application.

        users_setStatus(String status,  Boolean clear,  Boolean status_includes_verb,  Object onRequestCompleted)
        The preferred way to update the user's status is via FB.Connect.streamPublish.
        */
    }

    if (loginComponent.isLoading) {
        loginComponent.statusChanged.connect(r.login);
    } else {
        r.login();
    }

    return r;
}


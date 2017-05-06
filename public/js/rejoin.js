
var session;
var auth2;

function ajaxerror(error) {
    // a native xhr does not auto-parse its responseJSON.
    console.log("ajax fail: " + error.status + ': ' + error.statusText);
    var e_json = error.responseText || '{}';
    var e;
    try { e=JSON.parse(e_json) } catch(parse_err) { e={error:parse_err} }
    var msg = e && e.error? e.error: 'problems with server';
    $('#status-line').text(msg);
}

function init() {

    session = JSON.parse($('#session').html());
    //console.log("session %o", session);

    gapi.load('auth2', function(){
        gapi.auth2.init({}).then(function(){
            auth2 = gapi.auth2.getAuthInstance();
            auth2.isSignedIn.listen(signinChanged);
            auth2.then(function(){
                if (auth2.isSignedIn.get()) {
                    console.log("is signed in.");
                    signinChanged(true);
                    return;
                }
                $('.unknown').show();
                $('.known').hide();
                gapi.signin2.render('signin');
            });
        })
    });


    $('.button').each(function(i){
        var $this = $(this);
        var icon1 = $this.data('icon1');
        var icon2 = $this.data('icon2');
        if (!icon1 && !icon2) return $this.button();
        var keeptext = !$this.hasClass('notxt');
        $this.button({icons:{primary:icon1,secondary:icon2},text:keeptext});
    });

    $('a.bigbut').button().click(vote);
}

function vote(ev) {
    if (!auth2.isSignedIn.get()) {
        alert('Please sign in first with your Google ID so you can allow us to record your vote.');
        return;
    }
    var how = $(this).attr('id');
    $.post("vote/" + how + '.json').done(voted);
}

function voted(data) {
    //console.log("data: %o", data);
    if (!data.result || data.result != 'ok' || data.stay<0) return;
    $('h1#stay').text(data.stay);
    $('h1#quit').text(data.quit);
    window.location = '/';
}

function identity_done() {
    window.location = '/';
    /*
    console.log("new login 2. profile %o", profile);
    $('a#identity-imglnk img').attr('src', profile.Ph)
                              .attr('title', "Google Account: "+profile.wc+"\n ("+profile.hg+")");
    $('div.identity-line a#name').text("Hi, " + profile.wc);
    $('.unknown').hide();
    $('.known').show();
    */
}

function signinChanged(bSignedIn) {
    // signed in:
    if (bSignedIn) {
        var googleUser = auth2.currentUser.get();
        var profile = googleUser.getBasicProfile();
        var id = profile.getId();
        if (session.tokeninfo && session.tokeninfo.sub == id) {
            //console.log("old login: " + id);
            $('.unknown').hide();
            $('.known').show();
            return;
        }
        var auth_response = googleUser.getAuthResponse();
        console.log("new login.  auth response %o", auth_response);
        $.post('/oauth2/signin.json', {id_token: auth_response.id_token})
         .done(identity_done)
         .fail(identity_fail);
        return;
    }
    // signed out:
    $.post('/oauth2/signout.json')
        .done(function() { document.location = '/' })
        .fail(identity_fail);
}

function identity_fail(jqXHR) {
    console.log("identity fail: " + jqXHR.status + ': ' + jqXHR.statusText);
    var more = jqXHR.responseJSON;
    if (more && more.error) {
        $('#status-line').text(more.error);
        alert('Experiencing server-side problems.  Will now sign out.  Please re-try later');
    }
    signOut();
}

function signOut() {
    console.log("sign out now");
    gapi.auth2.getAuthInstance().signOut();
}

function onFail(info) {
    console.log("failed.. %o", info);
}

$(init);


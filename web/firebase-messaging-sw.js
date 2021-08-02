importScripts("https://www.gstatic.com/firebasejs/8.2.5/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.2.5/firebase-messaging.js");
firebase.initializeApp({
    apiKey: "AIzaSyAZK58TvUj3ry4e45sHMdTTz6LUwYTKf7E",
    authDomain: "ccf-reseller-web-app.firebaseapp.com",
    projectId: "ccf-reseller-web-app",
    storageBucket: "ccf-reseller-web-app.appspot.com",
    messagingSenderId: "808239604896",
    appId: "1:808239604896:web:d4e80c8cc3c33a5e9015c5",
    measurementId: "G-2JKFYY1Y73"
});
const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});
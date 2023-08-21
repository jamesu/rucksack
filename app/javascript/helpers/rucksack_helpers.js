
export default {

  requestIframeScript: function(el, params, callback) {
    var strName = ("uploader" + (new Date()).getTime());
    var jFrame = $( "<iframe name=\"" + strName + "\" src=\"about:blank\" />" );
    jFrame.css( "display", "none" );
    var us = this;

    jFrame.load(function(evt){
      var objUploadBody = window.frames[ strName ].document.getElementsByTagName( "body" )[ 0 ];
      var jBody = $(objUploadBody);

      // Safari fix
      if (!objUploadBody.innerHTML)
        return;

      // Ugly hack
      us.get(objUploadBody.innerHTML, params, callback);

      setTimeout(function(){
        jFrame.remove();
      }, 800);
    });

    $("body:first").append(jFrame);    
    $(el).attr('target', strName);
  },

  autofocus: function(el) {
    el.find('.autofocus')[0].focus();
  },

  get: function(url, data, callback) {
    var dataStr = data == null ? "" : "?" + (new URLSearchParams(data)).toString();

    return fetch(url + dataStr, {
      headers: {
        "Accept": "application/javascript"
      }
    }).then(callback);
  },

  request: function(el, callback) {
    var formData = new FormData(el[0]);
    console.log(formData);

    return fetch(el.attr('action'), {
      headers: {
        "Accept": "application/javascript"
      },
      method: "POST",
      body: formData
    }).then(response => {
      const contentType = response.headers.get("Content-Type");
      if (contentType && contentType.includes("text/javascript")) {
        return response.text();
      } else {
        throw new Error("Response is not JavaScript");
      }
    }).then(jsContent => {
      // Handle the JavaScript content
      eval(jsContent); // Example: execute the JavaScript content
    }).then(callback);
  },

  del: function(url, data, callback) {

    const authenticityToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");

    data = data == null ? {} : data;

    data['authenticity_token'] = authenticityToken;

    return fetch(url, {
      method: "DELETE",
      body: JSON.stringify(data),
      headers: {
        "Accept": "application/javascript",
        "Content-Type": 'application/json',
      }
    }).then(response => {
      const contentType = response.headers.get("Content-Type");
      if (contentType && contentType.includes("text/javascript")) {
        return response.text();
      } else {
        throw new Error("Response is not JavaScript");
      }
    }).then(jsContent => {
      // Handle the JavaScript content
      eval(jsContent); // Example: execute the JavaScript content
    }).then(callback);
  },

  post: function(url, data, callback) {

    const authenticityToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");

    data = data == null ? {} : data;

    data['authenticity_token'] = authenticityToken;

    console.log('post', data)

    return fetch(url, {
      method: "POST",
      body: JSON.stringify(data),
      headers: {
        "Accept": "application/javascript",
        "Content-Type": 'application/json',
      }
    }).then(response => {
      const contentType = response.headers.get("Content-Type");
      if (contentType && contentType.includes("text/javascript")) {
        return response.text();
      } else {
        throw new Error("Response is not JavaScript");
      }
    }).then(jsContent => {
      // Handle the JavaScript content
      eval(jsContent); // Example: execute the JavaScript content
    }).then(callback);
  },

  put: function(url, data, callback) {

    const authenticityToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");

    data = data == null ? {} : data;

    data['authenticity_token'] = authenticityToken;

    console.log('put url=', url);
    console.log('put data:', data);

    return fetch(url, {
      method: "PUT",
      body: JSON.stringify(data),
      headers: {
        "Accept": "application/javascript",
        "Content-Type": 'application/json',
      }
    }).then(response => {
      const contentType = response.headers.get("Content-Type");
      if (contentType && contentType.includes("text/javascript")) {
        return response.text();
      } else {
        throw new Error("Response is not JavaScript");
      }
    }).then(jsContent => {
      // Handle the JavaScript content
      eval(jsContent); // Example: execute the JavaScript content
    }).then(callback);
  }
};
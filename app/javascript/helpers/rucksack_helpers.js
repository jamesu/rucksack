
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
    return fetch(url, {
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
      body: formData,
      success: callback
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
    if (!data['_method'])
    {
      data['_method'] = 'DELETE';
    }

    data['authenticity_token'] = authenticityToken;

    return fetch(url, {
      method: "POST",
      data: JSON.stringify(data),
      dataType: 'application/json',
      success: callback
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
    if (!data['_method'])
    {
      data['_method'] = 'PUT';
    }

    data['authenticity_token'] = authenticityToken;

    console.log('post', data)

    return fetch(url, {
      method: "POST",
      data: JSON.stringify(data),
      dataType: 'application/json',
      success: callback
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
    if (!data['_method'])
    {
      data['_method'] = 'PUT';
    }

    data['authenticity_token'] = authenticityToken;

    return fetch(url, {
      method: "POST",
      data: JSON.stringify(data),
      dataType: 'application/json',
      success: callback
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
/*

import Elm.Kernel.Utils exposing (Tuple2)
import Elm.Kernel.Scheduler exposing (binding, succeed, fail)
import WebGL.Texture as Texture exposing (LoadError, SizeError)

*/
// eslint-disable-next-line no-unused-vars
var _Texture_loadCube = F6(function (xPosUrl, xNegUrl, yPosUrl, yNegUrl, zPosUrl, zNegUrl) {
  return __Scheduler_binding(function (callback) {
    var images = {
      xPos: new Image(),
      xNeg: new Image(),
      yPos: new Image(),
      yNeg: new Image(),
      zPos: new Image(),
      zNeg: new Image()
    }

    function createTexture(gl) {
      // console.log('createTexture TEXTURE_CUBE_MAP');
      var texture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_CUBE_MAP, texture);
      gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_X, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, images.xPos);
      gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, images.xNeg);
      gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, images.yPos);
      gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, images.yNeg);
      gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, images.zPos);
      gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, images.zNeg);

      gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
      gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
      gl.bindTexture(gl.TEXTURE_CUBE_MAP, null);
      return texture;
    }


    var loaded = 0;
    var errors = 0;
    function onImageLoad(event) {
      var img = event.target;
      loaded++;
      console.log("loaded", loaded);
      var width = img.width;
      var height = img.height;
      var widthPowerOfTwo = (width & (width - 1)) === 0;
      var heightPowerOfTwo = (height & (height - 1)) === 0;
      var isSizeValid = (widthPowerOfTwo && heightPowerOfTwo);
      console.log('isSizeValid', isSizeValid)
      if (!isSizeValid) {
        errors++
      }

      if (loaded === 6) {
        if (errors === 0) {
          callback(__Scheduler_succeed({
            $: __0_TEXTURE,
            __$createTexture: createTexture,
            __width: width,
            __height: height
          }));
        } else {
          callback(__Scheduler_fail(A2(
            __Texture_SizeError,
            width,
            height
          )));
        }
      }
    }

    function onError(e) {
      console.log("error", e);
      callback(__Scheduler_fail(__Texture_LoadError));
    }

    images.xPos.onload = onImageLoad;
    images.xNeg.onload = onImageLoad;
    images.yPos.onload = onImageLoad;
    images.yNeg.onload = onImageLoad;
    images.zPos.onload = onImageLoad;
    images.zNeg.onload = onImageLoad;

    images.xPos.onerror = onError;
    images.xNeg.onerror = onError;
    images.yPos.onerror = onError;
    images.yNeg.onerror = onError;
    images.zPos.onerror = onError;
    images.zNeg.onerror = onError;

    images.xPos.crossOrigin = "Anonymous";
    images.xNeg.crossOrigin = "Anonymous";
    images.yPos.crossOrigin = "Anonymous";
    images.yNeg.crossOrigin = "Anonymous";
    images.zPos.crossOrigin = "Anonymous";
    images.zNeg.crossOrigin = "Anonymous";

    images.xPos.src = xPosUrl;
    images.xNeg.src = xNegUrl;
    images.yPos.src = yPosUrl;
    images.yNeg.src = yNegUrl;
    images.zPos.src = zPosUrl;
    images.zNeg.src = zNegUrl;
  });
});

// eslint-disable-next-line no-unused-vars
var _Texture_load = F6(function (magnify, mininify, horizontalWrap, verticalWrap, flipY, url) {
  var isMipmap = mininify !== 9728 && mininify !== 9729;
  return __Scheduler_binding(function (callback) {
    var img = new Image();
    function createTexture(gl) {
      var texture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, flipY);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, magnify);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, mininify);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, horizontalWrap);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, verticalWrap);
      if (isMipmap) {
        gl.generateMipmap(gl.TEXTURE_2D);
      }
      gl.bindTexture(gl.TEXTURE_2D, null);
      return texture;
    }
    img.onload = function () {
      var width = img.width;
      var height = img.height;
      var widthPowerOfTwo = (width & (width - 1)) === 0;
      var heightPowerOfTwo = (height & (height - 1)) === 0;
      var isSizeValid = (widthPowerOfTwo && heightPowerOfTwo) || (
        !isMipmap
        && horizontalWrap === 33071 // clamp to edge
        && verticalWrap === 33071
      );
      console.log('isSizeValid', isSizeValid)
      if (isSizeValid) {
        callback(__Scheduler_succeed({
          $: __0_TEXTURE,
          __$createTexture: createTexture,
          __width: width,
          __height: height
        }));
      } else {
        callback(__Scheduler_fail(A2(
          __Texture_SizeError,
          width,
          height
        )));
      }
    };
    img.onerror = function () {
      callback(__Scheduler_fail(__Texture_LoadError));
    };
    if (url.slice(0, 5) !== 'data:') {
      img.crossOrigin = 'Anonymous';
    }
    img.src = url;
  });
});

// eslint-disable-next-line no-unused-vars
var _Texture_size = function (texture) {
  return __Utils_Tuple2(texture.__width, texture.__height);
};

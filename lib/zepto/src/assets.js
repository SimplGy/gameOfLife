//     Zepto.js
//     (c) 2010, 2011 Thomas Fuchs
//     Zepto.js may be freely distributed under the MIT license.

(function($){
  var cache = [], timeout;

  // ### $.fn.remove
  //
  // Remove element from DOM
  //
  // *Example:*
  //
  //     $('#projects, .comments').remove();
  //
  $.fn.remove = function(){
    return this.each(function(){
      if(this.parentNode !== null){
        if(this.tagName == 'IMG'){
          cache.push(this);
          this.src = 'data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=';
          if (timeout) clearTimeout(timeout);
          timeout = setTimeout(function(){ cache = [] }, 60000);
        }
        this.parentNode.removeChild(this);
      }
    });
  }
})(Zepto);

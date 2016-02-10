var jsdom = require('jsdom');

jsdom.env('http://robert-kowalski.de/', [
  'http://code.jquery.com/jquery-1.7.1.min.js'
], listAllArticles);

function listAllArticles(errors, window) {  
  var $ = window.$;
      
  $('article').find('header')
    .find('a')
      .each(function(i, element) {
          console.log($(element).text()); 
      });
};

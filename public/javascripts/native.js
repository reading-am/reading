var native = {is: (typeof window.fluid != 'undefined' ? 'fluid' : typeof window.platform != 'undefined' ? 'prism' : false)};

switch(native.is){
  case 'fluid':
    native.badge = function(text){
      window.fluid.dockBadge = text;
    }
    native.notify = function(input){
      window.fluid.showGrowlNotification(input);
    }
    break;
  case 'prism':
    native.badge = function(text){
      window.platform.icon().badgeText = text;
    }
    native.notify = function(input){
      window.platform.showNotification(input.title, input.description, input.icon);
    }
    break;
  default:
    native.badge = native.notify = function(){};
}

if(native.is){

window.document.title = '✌ Reading';
$(function(){ $('head').append('<link rel="stylesheet" href="stylesheets/native.css" type="text/css">'); });

}

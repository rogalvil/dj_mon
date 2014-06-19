//= require dj_mon/bootstrap_tooltip
//= require dj_mon/bootstrap_tab
//= require dj_mon/bootstrap_popover
//= require dj_mon/bootstrap_modal

//TESTING
$(function(){

  $('a[rel=popover]').live('mouseenter', function(){
    $(this).popover('show');
  });

  $('a[rel=modal]').live('click', function(){
    var content = $(this).data('content')
    $($('.modal')).show();
    $('.modal-body code').html(content);
  });

  $('[data-dismiss="modal"]').live('click', function(){
    $('.modal').hide();
  });

  $('select.queue').change(function(){
    if($(this).val()=='**Filter By Queue**'){
      return false
    }else{
      var queue = $(this).val()
      var url = $('.nav li.active a').attr('href')
      url+='?queue='+queue
      window.location.href = url
    }
  })

  $('.nav-tabs li.active').removeClass('active');
  var path = window.location.pathname;
  $('.nav-tabs li').each(function(){
    if (path.indexOf($.trim($(this).text().toLowerCase())) >=0){$(this).addClass('active')};
  })
})


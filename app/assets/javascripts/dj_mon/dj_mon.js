//= require dj_mon/bootstrap_tooltip
//= require dj_mon/bootstrap_tab
//= require dj_mon/bootstrap_popover
//= require dj_mon/bootstrap_modal
//= require dj_mon/mustache

$(function(){

  $('a[data-toggle="tab"]').bind('shown', function(e) {
    var currentTab = e.target;
    var tabContent = $($(currentTab).attr('href'));
    var dataUrl = tabContent.data('url');

    $.getJSON(dataUrl).success(function(data){
      var template = $('#dj_reports_template').html();
      if(data.dj_reports.length > 0)
        var output = Mustache.render(template, data.dj_reports);
      else
        var output = "<div class='alert centered'>No Jobs</div>";
      tabContent.html(output);
      $(".pagination").removeData();
      $(".pagination li:first").addClass("disabled");
    });

          paginateData(currentTab, tabContent);
  })

  function paginateData(currentTab, tabContent){
    currentTab = currentTab
    tabContent = tabContent
    $('.pagination a').click(function(){
      if ($('.pagination').data("current_page") == undefined){
        var current_page = 1
      }else{
        var current_page = parseInt($('.pagination').data("current_page"))
      };

      if ($(this).text().substring(0,4) == "Next"){
        var go_to_page = current_page + 1
      }else{
        var go_to_page = current_page - 1
      };

      var pageLink = this.href.split("?").shift() + ( "/" + currentTab.text.toLowerCase() + "?page="+go_to_page)

      $.getJSON(pageLink, null, null, 'script').success(function(data){
        var template = $('#dj_reports_template').html();
        if(data.dj_reports.length > 0){
          var output = Mustache.render(template, data.dj_reports);
        }
        else
        {
          var output = "<div class='alert centered'>NO MO JOBS</div>";
        }
        tabContent.html(output);
        $('.pagination').data("current_page", go_to_page);
        if (go_to_page==1){
          $('.pagination li:first').addClass("disabled");
        }
        else
        {
          $('.pagination li:first').removeClass("disabled");
        }
      });
      return false;
    });
  }

  $('.nav.nav-tabs li.active a[data-toggle="tab"]').trigger('shown');

  $('a[rel=popover]').live('mouseenter', function(){
    $(this).popover('show');
  });

  $('a[rel=modal]').live('click', function(){
    var template = $($(this).attr('href')).html();
    var output = Mustache.render(template, { content: $(this).data('content') });
    $(output).appendTo($('body')).show();
  });

  $('[data-dismiss="modal"]').live('click', function(){
    $('.modal').hide().remove();
  });

  (function refreshCount() {
    $.getJSON(dj_counts_dj_reports_url).success(function(data){
      var template = $('#dj_counts_template').html();
      var output = Mustache.render(template, data);
      $('#dj-counts-view').html(output);
      setTimeout(refreshCount, 5000);
    });
  })();

})


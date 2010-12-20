Pages = {
  update_last_saved_status: function(options) {

  //$.ajax({
  //  url: options.url,
  //  beforeSend: function(xhr) {
  //    xhr.setRequestHeader("Accept", "application/json");
  //  },
  //  success: function(data) {
  //    var updated_at = data['k3_page']['updated_at'];
  //    $('#last_saved_status').html(updated_at);
  //  },
  //});

    $.ajax({
      url: options.url + '/last_saved_status',
      success: function(data) {
        $('#last_saved_status').html(data);
      },
    });
  }
}

function Pages() {
}
function PagesSerialize() {
  $('[data-serialize_to]').each(function(index) {
    console.log('Serializing', $(this), 'to', $(this).attr('data-serialize_to'))
  })
}

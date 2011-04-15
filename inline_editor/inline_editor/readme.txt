This is an inline editor prototype/experiment

proper behaviors when toggling a tag like bold/italic/link/etc:
1. no overlapping or nesting (..<new>..</new>..):
  a. just stick new tag straight in!
2. new tag is nested in parent, touching neither side of parent (..<old>..<new>..</new>..</old>..):
  a. edits attributes of parent tag (ex: <a href>, note: same as 8.a.)
  b. split parent and turn tag off for selected area (ex: <b>, <i>, NOTE: similar UI behavior to 5.b. and 8.b. and inverse of 7.a.)
  c. ignore nesting, just stick new tag straight in (ex: usually other non-similar tags)
3. new tag has a nested child, touching neither side of parent (..<new>..<old>..</old>..</new>..):
  a. nested tag moves to its parent boundaries, and its settings become default for new tag? (ex: <a href>, same as 9.a.)
  b. nested tag is removed and new parent one is created (ex: <b>, <i>, same as 9.b.)
  c. ignore nesting, just stick new tag straight in (ex: usually other non-similar tags)
4. split tag (..<old>..<new>..</old>..</new>..):
  a. split old partial tag selected, keep new one together
  b. split new tag, keep old partial one together
  c. extend split tag to include new area too (NOTE: similar to 6.a.)
5. matches tag (exactly nested one way or the other) (..<old><new>..</new></old>..) (..<new><old>..</old></new>..):
  a. edits attributes of matching tag (ex: <a href>)
  b. turn off tag (ex: most similar inline tags, NOTE: similar UI behavior to 2.b. and 8.b.)
  c. ignore matching tag, just stick new tag straight in (ex: usually other non-similar tags)
6. abutts tag (exactly butts up against other tag on one side, no overlap with it) (..<old>..</old><new>..</new>..)
  a. new tag merges into / extends existing tag (ex: <b>, <i>, NOTE: similar to 4.c. and inverse of 8.b.)
  b. ignore abutting tag, just stick new tag straight in (ex: usually other non-similar tags)
7. between tags (exactly nestled between two other abutting tags, not overlap with either) (..<old>..</old><new>..</new><old>..</old>..)
  a. new tag merges into both sides, bridging the whole area into one tag (ex: <b>, <i>, NOTE: inverse of 2.b.)
  b. ignore two abutting tags, just stick new tag straight in (ex: usually other non-similar tags)
8. new tag is nested in parent, and butts up against one side of parent (..<old>..<new>..</new></old>..):
  a. edits attributes of parent tag (ex: <a href>, NOTE: same as 2.a.)
  b. split parent and turn tag off for selected area (ex: <b>, <i>, NOTE: similar UI behavior to 2.b. and 5.b. and inverse of 6.a.)
  c. ignore nesting, just stick new tag straight in (ex: usually other non-similar tags)
9. new tag has a nested child, that meets one side of parent (..<new>..<old>..</old></new>..):
  a. nested tag moves to its parent boundaries, and its settings become default for new tag? (ex: <a href>, same as 3.a.)
  b. nested tag is removed and new parent one is created (ex: <b>, <i>, same as 3.b.)
  c. ignore nesting, just stick new tag straight in (ex: usually other non-similar tags)


  // $('.buttons .toggleBold').mousedown(function() { return wrapSelectionWithTag('b'); });
  // $('.buttons .toggleItalic').mousedown(function() { return wrapSelectionWithTag('i'); });

  // function wrapSelectionWithTag(tag) {
  //   if (! $(document.activeElement).hasClass('editable')) return false;
  // 
  //   var sel = window.getSelection();
  //   var range = sel.getRangeAt(0);
  //   var is_forward = sel.anchorNode == range.startContainer && sel.anchorOffset == range.startOffset;
  //   var elem = document.createElement(tag);
  //   
  //   // "surroundContents" method
  //   // won't handle split tags (throws an error)
  //   // does not do any merging with adjacent or nested
  //   // range.surroundContents(elem);
  // 
  //   // "extractContents/insertNode" method
  //   // does split tags, but in a somewhat heavy handed way...
  //   // does not do any merging with adjacent or nested
  //   $(elem).append(range.extractContents());
  //   range.insertNode(elem);
  // 
  //   range.selectNode(elem);
  //   if (is_forward) {
  //     sel.addRange(range);
  //   } else {
  //     sel.collapse(range.endContainer, range.endOffset);
  //     sel.extend(range.startContainer, range.startOffset)
  //   }
  //   
  //   refreshButtons();
  //   if (navigator.userAgent.match(/MSIE/)) $(document.activeElement).one('blur', function() { this.focus(); });
  //   return false;
  // }

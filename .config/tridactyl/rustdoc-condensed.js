(function() {
  // This function forces rustdoc to collapse documentation for all items,
  // except for the methods defined in an impl block and the primary type's
  // declaration. This is the most natural view IMO, since it provides the
  // primary type along with an easy to scan overview of available methods.
  //
  // rustdoc does seemingly have user settings that purport to make this the
  // default, but I could never cause them to work in a reliably consistent
  // way. This is especially useful when writing documents, where you commonly
  // want to refresh and look at the docs for the specific item you're working
  // on. This mini-script will automatically scroll to and expand the currently
  // selected method.
  //
  // I used the tridactyl Firefox extension to bind this script to `,z` with
  // the following in my tridactylrc:
  //
  //     bind ,z composite jsb tri.native.run('cat path/to/rustdoc-condensed.js') | js -p eval(JS_ARG.content)

  // get the currently selected doc item from URL's hash fragment
  // e.g., in `struct.BStr.html#method.words`, this returns `method.words`.
  function getPageId() {
    var id = document.location.href.split("#")[1];
    if (id) {
      return id.split("?")[0].split("&")[0];
    }
    return null;
  }

  // collapse everything, with an extra click in case things are partially
  // collapased already
  const toggleAll = document.getElementById('toggle-all-docs');
  if (toggleAll.className.indexOf('will-expand') > -1) {
    toggleAll.click();
  }
  toggleAll.click();

  // re-expand primary impls
  const impls = document.getElementsByClassName('impl');
  for (let i = 0; i < impls.length; i++) {
    // but don't expand every impl, just the ones on this type
    if (!/^impl(-\d+)?$/.test(impls[i].id)) {
      continue;
    }

    const toggles = impls[i].getElementsByClassName('collapse-toggle');
    for (let j = 0; j < toggles.length; j++) {
      // If it's already expanded, then let it be. In newer versions of
      // rustdoc, collapsing everything doesn't collapse the methods, so we
      // don't need to do anything.
      if (toggles[j].innerText == '[−]') {
        continue;
      }
      toggles[j].click();
    }
  }

  // expand type declaration docs
  const main = document.getElementById('main');
  const wrapper = document.getElementsByClassName('toggle-wrapper')[0];
  wrapper.getElementsByTagName('a')[0].click();

  // re-expand specific method declaration, and scroll to it
  const pageId = getPageId();
  if (pageId !== null) {
    const method = document.getElementById(pageId);
    method.getElementsByClassName('collapse-toggle')[0].click();
    method.scrollIntoView();
  }
})()

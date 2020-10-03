{
  let loaded = false;
  addOnInit(() => {
    loaded = true;
  })


  // Mocha "before all" hook that waits for module init.
  before('wait for init', (done) => {
    const i = setInterval(() => {
      if (loaded) {
        clearInterval(i);
        done();
      }
    }, 5);
  });
}

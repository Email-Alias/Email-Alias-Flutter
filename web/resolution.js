if (screen.width < 450) {
  document.body.classList.add('small_screen');
  document.getElementsByClassName('html')[0].classList.add('small_screen');
}
else {
  document.body.classList.add('large_screen');
  document.getElementsByClassName('html')[0].classList.add('large_screen');
}
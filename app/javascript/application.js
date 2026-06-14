// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import Swal from 'sweetalert2'

window.Swal = Swal

document.addEventListener('turbo:load', () => {
  document.querySelectorAll('[data-confirm-swal]').forEach(element => {
    element.addEventListener('click', (event) => {
      event.preventDefault();
      
      Swal.fire({
        title: 'Você tem certeza?',
        text: element.getAttribute('data-confirm-text') || "Essa ação não pode ser desfeita!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d71920',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sim, confirmar!',
        cancelButtonText: 'Cancelar'
      }).then((result) => {
        if (result.isConfirmed) {
          Turbo.visit(element.getAttribute('href'), { 
            method: element.getAttribute('data-turbo-method') || 'get' 
          });
        }
      });
    });
  });
});
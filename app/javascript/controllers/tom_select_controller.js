import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Esse método roda automaticamente assim que o select entra na tela
    if (typeof TomSelect === "undefined") return

    this.ts = new TomSelect(this.element, {
      create: false,
      maxItems: 1,
      placeholder: "Busque pelo nome ou código...",
      noResultsText: "Lanche não encontrado",
      onChange: () => {
        // Dispara uma notificação nativa para o formulário recalcular os totais
        this.element.dispatchEvent(new Event('change', { bubbles: true }))
      }
    })
  }

  disconnect() {
    // Esse método roda automaticamente quando você muda de página, destruindo o cache velho
    if (this.ts) {
      this.ts.destroy()
    }
  }
}
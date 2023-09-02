# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/helpers", under: "helpers"
pin "cash-dom", to: "https://ga.jspm.io/npm:cash-dom@8.1.5/dist/cash.js"
pin "velocity-animate", to: "https://ga.jspm.io/npm:velocity-animate@2.0.6/velocity.min.js"
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.0/modular/sortable.esm.js"
pin "trix"
pin "@rails/actiontext", to: "actiontext.js"

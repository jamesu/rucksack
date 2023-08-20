# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/helpers", under: "helpers"
pin "@shopify/draggable", to: "https://ga.jspm.io/npm:@shopify/draggable@1.0.0-beta.8/lib/draggable.bundle.js"
pin "cash-dom", to: "https://ga.jspm.io/npm:cash-dom@8.1.5/dist/cash.js"
pin "velocity-animate", to: "https://ga.jspm.io/npm:velocity-animate@2.0.6/velocity.min.js"

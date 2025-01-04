
template ntmlTemplate*[T](name: untyped, children: untyped) =
  template `name`*(props {.inject.}: T) =
    result = "<template id=\"" & astToStr(`name`) & "_ntml_component_template\">"
    `children`
    result.add("</template>")

    proc renderTemplate() =
      let templ = document.getElementById(astToStr(`name`) & "_ntml_component_template")
      if templ.content != nil:
        let clone = templ.content.cloneNode(true)
        document.body.appendChild(clone)

    proc onDOMContentLoaded(e: Event) =
      renderTemplate()

    document.addEventListener("DOMContentLoaded", onDOMContentLoaded)

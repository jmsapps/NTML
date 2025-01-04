template ntmlTemplate*[T](name: untyped, children: untyped) =
  template `name`*(props {.inject.}: T) =
    result = "<div id=\"" & astToStr(`name`) & "_ntml_component_template_container\">"
    result.add("<template id=\"" & astToStr(`name`) & "_ntml_component_template\">")
    `children`
    result.add("</template>")
    result.add("</div>")

    proc renderTemplate() =
      let containerId = cstring(astToStr(`name`) & "_ntml_component_template_container")
      let templateId = cstring(astToStr(`name`) & "_ntml_component_template")

      let container = document.getElementById(containerId)
      let templ = document.getElementById(templateId)

      if templ.content != nil:
        let clone = templ.content.cloneNode(true)
        container.appendChild(clone)

    proc onDOMContentLoaded(e: Event) =
      renderTemplate()

    document.addEventListener("DOMContentLoaded", onDOMContentLoaded)

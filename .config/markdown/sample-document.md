# Sample Document

This is a **general-purpose** sample document used to exercise the markdown
tooling. It intentionally includes *most* of the common markdown elements so
that the base stylesheet can be reviewed at a glance.

## Paragraphs and Text Styles

Markdown supports **bold**, *italic*, ***bold italic***, ~~strikethrough~~, and
`inline code`. You can also link to external resources such as
[the CommonMark spec](https://commonmark.org). Longer paragraphs wrap naturally
and should render with comfortable line-height and measure in the base style.

> Blockquotes are handy for callouts, pull quotes, or highlighting an important
> note that deserves to stand apart from the surrounding text.

## Lists

An unordered list:

- First item
- Second item with a nested list:
  - Nested item one
  - Nested item two
- Third item

An ordered list:

1. Preheat the oven
2. Mix the ingredients
3. Bake until golden

A task list:

- [x] Write the sample document
- [ ] Review the stylesheet
- [ ] Ship it

## Images

![Sample figure showing a stylized chart](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0ODAiIGhlaWdodD0iMTgwIiB2aWV3Qm94PSIwIDAgNDgwIDE4MCI+PHJlY3Qgd2lkdGg9IjQ4MCIgaGVpZ2h0PSIxODAiIGZpbGw9IiMwNjQ1YWQiLz48Y2lyY2xlIGN4PSI5MCIgY3k9IjkwIiByPSI1NSIgZmlsbD0iI2ZmZDE2NiIvPjxyZWN0IHg9IjE4MCIgeT0iNTUiIHdpZHRoPSIyMjAiIGhlaWdodD0iMjAiIHJ4PSI2IiBmaWxsPSIjZmZmZmZmIi8+PHJlY3QgeD0iMTgwIiB5PSI5NSIgd2lkdGg9IjE2MCIgaGVpZ2h0PSIyMCIgcng9IjYiIGZpbGw9IiNhMGM0ZmYiLz48dGV4dCB4PSIyNDAiIHk9IjE2MCIgZmlsbD0iI2ZmZmZmZiIgZm9udC1mYW1pbHk9InNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjAiIHRleHQtYW5jaG9yPSJtaWRkbGUiPlNhbXBsZSBGaWd1cmU8L3RleHQ+PC9zdmc+)

The image above is an inline SVG data URI so the sample stays self-contained.

## Tables

| Feature      | Supported | Notes                          |
| ------------ | :-------: | ------------------------------ |
| Headings     |    Yes    | Six levels, `h1`–`h6`          |
| Tables       |    Yes    | GFM pipe tables                |
| Code blocks  |    Yes    | Fenced, with info strings      |
| Task lists   |    Yes    | Requires the GFM extension     |

## Code Blocks

Inline code like `git status` sits within a sentence. Fenced blocks preserve
whitespace and can carry a language hint:

```python
def greet(name: str) -> str:
    """Return a friendly greeting."""
    return f"Hello, {name}!"


print(greet("world"))
```

```bash
# Convert this document to a PDF using the base style
md-to-pdf sample-document.md sample-document.pdf
```

## Headings Deeper

### Third-Level Heading

Some supporting text under a third-level heading.

#### Fourth-Level Heading

##### Fifth-Level Heading

###### Sixth-Level Heading

---

That horizontal rule marks the end of the sample document.

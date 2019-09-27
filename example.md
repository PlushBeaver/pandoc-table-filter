---
title: Table Filter Example
table-templates:
  card:
    orientation: horizontal
    series:
    - title: Name
      id: name
    - title: Age
      id: age
    - title: Company
      id: company
    - title: Position
      id: position
    classes:
    - card
    - horizontal
---

```{=html}
<style>
table {
    border-collapse: collapse;
}
td, th {
    border: 1px solid gray;
    padding: 0.25em;
    vertical-align: top;
}

.horizontal td:first-child {
    font-weight: bold;
}

#measurements tr td:nth-child(n + 2) {
    text-align: right;
}

.card {
    margin: 0.5em;
    border: 2px solid black;
    width: 300px;
}
.card table {
    width: 100%;
}
.card td, .card th {
    border: none !important;
}
.card td:first-child::after {
    content: ":";
}
</style>
```

## Vertical Table

```{.table #roles}
series:
- title: No.
  special: number
  align: right
- title: Role
  id: role
- title: Responsibility
  id: resp
data:
- role: Developer
  resp: |
    * Produce *quality* `code`
    * Meet deadlines
- role: Manager
  resp: |
    * Coordinate developers
    * Produce accurate reports
```

* Row numbers are generated.
* Generated table inherits block classes and ID for styling and referencing.


## Horizontal Tables

```{.table .horizontal #measurements}
orientation: horizontal
caption: Measurements
series:
- title: "Current, mA"
  id: i
- title: "Voltage, V"
  id: v
data:
- i: 15
  v: 3,0
- i: 16
  v: 3,1
- i: 15
  v: 3,1
- i: 16
  v: 3,0
```

```{.table #tbl:john}
template: card
caption: Employee 1
data:
- name: John Doe
  age: 32
  company: Acme Inc.
  position: Senior Software Developer
```

```{.table #tbl:jane}
template: card
caption: Employee 2
data:
- name: Jane Doe
  age: 29
  company: Acme Inc.
  position: Project Manager
```

* ID is preserved for tables -@tbl:john and -@tbl:jane for `pandoc-crossref`.
* Header cells are TD´s styled with CSS `:first-child`.
* Row alignment has to be defined with styles.
* Table template (headings, alignment, etc.) reused from document metadata.
* Table templates can add classes to generated tables.

# SmallDoc

A JavaDoc-style documentation generator for Pharo Smalltalk.

## Installing

```st
Metacello new
  githubUser: 'Gabriel-Darbord' project: 'SmallDoc' commitish: 'main' path: 'src';
  baseline: 'SmallDoc';
  load
```

## Usage

Simply supply a list of package to document, a title, and an export path.
```st
SmallDoc
  write: Smalltalk packages
  to: Smalltalk imageDirectory / 'SmallDoc'
  title: 'All Pharo Packages'
```
Then open the generated `index.html` with your favorite web browser.

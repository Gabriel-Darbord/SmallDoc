# SmallDoc

A JavaDoc-style documentation generator for Smalltalk.

## Installing

```st
Metacello new
  githubUser: 'Gabriel-Darbord' project: 'SmallDoc' commitish: 'main' path: 'src';
  baseline: 'SmallDoc';
  load
```

## Usage

Simply supply a list of package to document, and an export path.
```st
SmallDoc
  write: Smalltalk packages
  to: Smalltalk imagePath asFileReference parent / 'SmallDoc'
```
Then open the generated `index.html` with your favorite navigator.

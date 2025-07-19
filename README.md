# gwbasic.vim

Ein Vim-Plugin für GW-BASIC-Entwicklung, mit folgenden Funktionen:

- Syntax-Highlighting für klassische GW-BASIC-Schlüsselwörter und Funktionen
- Automatische Zeilennummerierung beim Drücken von `<Enter>`
- `<Ctrl-Enter>` (oder `<Ctrl-J>`) fügt eine leere Zeile **ohne Zeilennummer** ein
- Tabs werden unterdrückt, stattdessen nur Spaces verwendet
- Befehl `:Renumber [n]` zum Neu-nummerieren aller BASIC-Zeilen (Standard: Schrittweite 10)

## Installation

Kopiere dieses Repository in dein Vim-Plugin-Verzeichnis:

```sh
git clone https://github.com/dein-benutzername/gwbasic.vim ~/.vim/pack/plugins/start/gwbasic.vim
```

Oder als manuelle Installation:

```sh
mkdir -p ~/.vim/{syntax,plugin,ftdetect}
cp syntax/gwbasic.vim ~/.vim/syntax/
cp plugin/gwbasic.vim ~/.vim/plugin/
cp ftdetect/gwbasic.vim ~/.vim/ftdetect/
```

## Nutzung

Einfach eine `.bas`, `.gwb`, oder `.gwbasic` Datei öffnen. Alles Weitere geschieht automatisch.

## Lizenz

MIT

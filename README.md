# gwbasic.vim

Ein minimalistisches Vim-Plugin für das Schreiben, Bearbeiten und Ausführen von GW-BASIC Programmen unter Linux, macOS oder Windows – ideal in Kombination mit [`pcbasic`](https://github.com/robhagemans/pcbasic).

## 🔧 Features

- Syntax-Hervorhebung für GW-BASIC Befehle, Funktionen und Statements
- Automatische Zeilennummerierung im 10er-Schritt nach [Return]
- Einfügen nicht-nummerierter Zwischenzeilen mit [Ctrl-J] (LFCR)
- Erzwingt ausschließlich Leerzeichen (Tabs werden zu Spaces)
- Automatisches Speichern im GW-BASIC ASCII-Format:
  - CRLF (`\r\n`) nach jeder normalen Zeile
  - LFCR (`\n\r`) für `Ctrl-J`-Zeilen
  - Abschließendes EOF-Zeichen `0x1A`
- Automatische Großschreibung aller GW-BASIC Befehle
- Integration mit `pcbasic` zum direkten Ausführen

## ⚙️ Installation mit vim-plug

```vim
Plug 'ssulser/gwbasic.vim'
```

Dann in Vim:

```vim
:source %
:PlugInstall
```

## ⌨️ Tastenkombinationen

| Tastenkombination | Beschreibung                                  |
|-------------------|-----------------------------------------------|
| `[Return]`        | Neue nummerierte Zeile mit +10                |
| `[Ctrl-J]`        | Fügt LFCR-Trenner (z. B. für Kommentare) ein  |
| `[Ctrl-Return]`   | Normales Verhalten (keine Sonderaktion)       |
| `[Ctrl-R]`        | Führt das aktuelle Programm mit `pcbasic` aus |

## 📦 Befehle

| Befehl            | Funktion                                      |
|-------------------|-----------------------------------------------|
| `:Renumber`       | Neu nummerieren (Standard: Schrittweite 10)   |
| `:Run`            | Speichern und ausführen mit `pcbasic`         |

## 📁 Dateiformat beim Speichern

Dieses Plugin ersetzt das `:w` Kommando durch eine eigene Speicherfunktion, die die Datei im klassischen GW-BASIC ASCII-Format speichert:

- **Normale Zeilen** → `CRLF` (0x0D 0x0A)
- **Spezialzeilen (Ctrl-J)** → `LFCR` (0x0A 0x0D)
- **EOF** → `0x1A`

## 🧪 Beispiel

```basic
10 PRINT "HELLO WORLD"
20 GOTO 10
```

## 💡 Voraussetzungen

- [pcbasic](https://github.com/robhagemans/pcbasic) im Systempfad (`$PATH`)
- Vim oder Neovim

## 📜 Lizenz

MIT License – © 2025 Simon Sulser

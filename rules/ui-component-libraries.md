# UI Component Libraries (Global)

## shadcn/ui Regeln

### NIEMALS shadcn/ui-Komponenten direkt modifizieren!
Dateien unter `components/ui/` sind **generiert** und werden bei Updates ueberschrieben.

**VERBOTEN:**
- `components/ui/button.tsx` direkt bearbeiten
- Styles in shadcn-Komponenten hardcoden
- shadcn-Komponenten kopieren statt erweitern

**ERLAUBT:**
- Wrapper-Komponenten erstellen: `components/custom/MyButton.tsx`
- Variants via `cva()` in eigenen Komponenten definieren
- `cn()` fuer bedingte Klassen nutzen
- `className` prop fuer einmalige Anpassungen

### Neue shadcn-Komponenten installieren
```bash
npx shadcn@latest add [component-name]
```
NIEMALS manuell aus Docs kopieren - immer CLI verwenden.

### Tailwind CSS + shadcn Pattern
```tsx
// RICHTIG: cn() fuer bedingte Klassen
<div className={cn("base-classes", condition && "conditional-class")} />

// FALSCH: String-Concatenation
<div className={"base " + (condition ? "active" : "")} />

// FALSCH: Inline Styles statt Tailwind
<div style={{ padding: '16px' }} />  // -> className="p-4"
```

### Composition Pattern
```tsx
// RICHTIG: shadcn erweitern via Wrapper
import { Button } from "@/components/ui/button";

export function SubmitButton({ children, ...props }) {
  return <Button variant="default" size="lg" {...props}>{children}</Button>;
}

// FALSCH: button.tsx direkt aendern
```

## Tailwind CSS Regeln

### Keine willkuerlichen Werte
```tsx
// FALSCH
<div className="p-[13px] text-[#1a2b3c]" />

// RICHTIG - Theme-Tokens verwenden
<div className="p-3 text-primary" />
```

### Responsive Design
- Mobile-first: `className="text-sm md:text-base lg:text-lg"`
- Container: `max-w-screen-xl mx-auto px-4`

### Dark Mode
- Immer beide Varianten: `className="bg-white dark:bg-slate-900"`
- CSS Variablen von shadcn nutzen: `bg-background text-foreground`

## Radix UI Primitives
- shadcn baut auf Radix auf - Radix direkt nur verwenden wenn shadcn keine Loesung bietet
- Accessibility (a11y) kommt durch Radix automatisch - nicht manuell aria-Attribute hinzufuegen die Radix schon setzt

# bootctrl for starlte

This folder is present to mirror the fuller PBRP layout seen in some newer device trees.

## Important for Galaxy S9 (starlte)
- `starlte` is typically a **non-A/B** Exynos device tree in recovery bring-up.
- The large `bootctrl` implementations seen in some PBRP repos are often **A/B + MediaTek/QCOM specific**.
- Copying those files directly (for example `android.hardware.boot@1.2-mtkimpl`) is not appropriate for this tree.

## When to add real source files here
Add real `bootctrl` code only if this tree is migrated to a true A/B boot flow and you have chipset-correct implementation.

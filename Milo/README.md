# Native development notes

For the app overview and build instructions, see the [repository README](../README.md).

All commands below run from the repository root after building `Milo.app`. Previews use an isolated preferences suite, do not change the normal session, and do not request notification permission.

## View snapshots

```sh
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo.png
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-focus.png --focus
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-rest.png --rest
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-settings.png --settings
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-plain.png --plain-cat
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-motion.png --animated --motion-frames
```

The scanline style is on by default. `--plain-cat` renders the original silhouette. `--animated --motion-frames` exports a second frame 0.9 seconds later with the suffix `.motion.png`. Without `--animated`, the cat remains still, including the scanlines.

Snapshots contain only the app's hosted view flattened over charcoal. They cannot capture desktop-sampled glass refraction; assess that in the live app.

## Glass and transition diagnostics

```sh
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-glass.png --exercise-glass
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-warp.png --exercise-transitions
Milo.app/Contents/MacOS/Milo --render-preview /tmp/milo-warp-reduced.png --exercise-transitions --reduce-motion-preview
```

The glass diagnostic exports clear, dark, solid, and settings variants plus a JSON report checking surface switching and session preservation. Individual snapshots also accept `--clear-glass`, `--dark-glass`, and `--solid`.

Transition diagnostics export a JSON report, settings/timer snapshots, and four Genie mesh frames. Checks cover rapid reversals, outside clicks, resizing, cleanup, and convergence on the menu icon. `--reduce-motion-preview` exercises the transition's fade fallback without changing system preferences.

## Notification diagnostics

```sh
Milo.app/Contents/MacOS/Milo --check-notifications /tmp/milo-notifications.json
```

This does not request permission or send an alert. When permission is already allowed, it briefly schedules a uniquely named future request, checks it, and cancels it. The normal timer's request is left alone. To verify actual delivery, use **Send test** in the app's Settings.

## Rendering and persistence

The cat is drawn from native vector paths. An isolated Canvas layer removes horizontal bands from the dark silhouette; eyes and pupils are drawn afterward to stay crisp. The same 30 fps timeline drives breathing, tail sway, and scanline movement. It pauses when the panel is hidden, animation is disabled, or Reduce Motion is enabled. The scanline appearance preference is stored separately so changing it does not reset the timer or reschedule notifications.

The menu and notification icons are not striped. A white radial glow fades to transparent behind the main cat, with no rectangular tile.

The glass surface uses the public `NSGlassEffectView` API. Settings and Reduced Transparency use solid surfaces. The compact timer is 420 × 224 points; settings expand only when needed.

Sessions are stored in the app's local preferences (`local.milo.personal`). Completion is reconciled against an absolute deadline and recorded once. No network service is used.

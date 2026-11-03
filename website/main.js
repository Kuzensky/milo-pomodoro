/* Milo landing page. No dependencies; without JavaScript the page is static
   but complete, and every effect respects Reduce Motion. */
(() => {
  'use strict';

  const DMG_URL = 'https://github.com/Kuzensky/milo-pomodoro/releases/latest/download/Milo.dmg';
  const EASE = 'cubic-bezier(.22, 1, .36, 1)';
  const root = document.documentElement;
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)');
  const $ = (sel, scope = document) => scope.querySelector(sel);
  const $$ = (sel, scope = document) => [...scope.querySelectorAll(sel)];
  const isStill = () => reduceMotion.matches || root.classList.contains('still');

  /* Download --------------------------------------------------------------- */

  function detectPlatform() {
    const ua = navigator.userAgent;
    const platform = navigator.userAgentData?.platform || navigator.platform || '';
    // iPadOS Safari reports itself as a Mac; touch support gives it away.
    if (/iPhone|iPad|iPod/.test(ua) || (/Mac/.test(platform) && navigator.maxTouchPoints > 1)) return 'ios';
    if (/Mac/.test(platform) || /Macintosh/.test(ua)) return 'mac';
    if (/Android/.test(ua)) return 'android';
    if (/Win/.test(platform)) return 'windows';
    if (/Linux|CrOS/.test(platform)) return 'linux';
    return 'unknown';
  }

  /**
   * What the download buttons say and where they go for this visitor.
   * @param {'mac'|'ios'|'android'|'windows'|'linux'|'unknown'} platform
   * @returns {{label: string, href: string, note: string}}
   */
  function downloadStateFor(platform) {
    const mac = { label: 'Download for Mac', href: DMG_URL, note: 'Free · macOS 26 or later · 780 KB' };
    // TODO(human): Milo only runs on Macs. Decide what everyone else sees.
    // Return a different { label, href, note } for platforms that can't run
    // the DMG, or return `mac` to offer the download to every visitor.
    return mac;
  }

  function applyDownloadState() {
    const platform = detectPlatform();
    const state = downloadStateFor(platform);
    const isDmg = state.href === DMG_URL;
    root.dataset.platform = platform;
    for (const link of $$('[data-download]')) {
      link.href = state.href;
      const label = $('[data-download-label]', link);
      // The compact nav and footer links keep saying "Download" when they download.
      if (label) label.textContent = isDmg && link.matches('.pill-sm, .footer a') ? 'Download' : state.label;
    }
    for (const note of $$('[data-download-note]')) note.textContent = state.note;
  }

  function setupToast() {
    const toast = $('[data-toast]');
    let timer = 0;
    const hide = () => { toast.hidden = true; clearTimeout(timer); };
    document.addEventListener('click', (event) => {
      const link = event.target.closest('[data-download]');
      if (!link || link.href !== DMG_URL) return;
      toast.hidden = false;
      clearTimeout(timer);
      timer = setTimeout(hide, 14000);
    });
    $('[data-toast-close]').addEventListener('click', hide);
    $('[data-toast-help]').addEventListener('click', hide);
    // Every link to the first-launch answer opens it, even if it was closed.
    document.addEventListener('click', (event) => {
      if (event.target.closest('a[href="#first-launch"]')) $('#first-launch').open = true;
    });
  }

  /* Milo, drawn from the SVG masters in Milo/Design/assets ----------------- */

  const POSES = {
    idle: {
      transform: 'translate(47 23) scale(.49)',
      look: 26,
      art: `<path class="fur tail" d="M568 552 C675 531 749 595 782 672 C818 756 788 846 711 889 C645 928 538 938 437 920 C384 917 349 902 367 857 C384 815 418 812 470 819 C554 830 625 817 672 786 C729 748 708 678 639 650 L583 634 Z"/>
        <path class="fur" d="M246 520 C298 481 415 484 491 501 C558 515 607 554 618 618 C622 690 563 757 480 772 L426 778 C410 813 366 831 334 808 C309 790 312 766 319 737 C286 761 245 752 216 736 C184 718 171 688 185 657 C200 625 223 613 220 572 Z"/>
        <path class="fur" d="M73 361 C89 237 170 122 275 46 C315 18 355 -2 381 11 C410 26 419 65 424 105 C469 115 505 144 540 166 C625 165 708 181 739 225 C770 263 738 329 704 378 C663 438 605 482 553 518 C487 565 397 596 309 591 C201 585 123 530 88 463 C73 435 65 396 73 361 Z"/>
        <path class="ear" d="M625 312 C664 288 705 275 735 272 C734 332 672 402 613 444 C619 395 625 357 625 312 Z"/>
        <g class="blink"><ellipse class="eye" cx="177" cy="345" rx="101" ry="162" transform="rotate(9 177 345)"/><ellipse class="eye" cx="434" cy="411" rx="133" ry="160" transform="rotate(-9 434 411)"/>
        <g class="look"><g class="pupils"><ellipse cx="185" cy="342" rx="65" ry="103" transform="rotate(9 185 342)"/><ellipse cx="441" cy="410" rx="85" ry="109" transform="rotate(-9 441 410)"/></g></g></g>`,
    },
    focus: {
      transform: 'translate(9 12) scale(.58)',
      look: 0,
      art: `<path class="fur tail" d="M558 535 C656 506 736 569 767 635 C789 680 783 741 760 751 C730 765 696 742 694 707 C691 658 664 641 620 636 L578 645 Z"/>
        <path class="fur" d="M262 498 C323 463 441 468 512 492 C580 514 609 568 610 623 C610 684 562 721 489 735 L427 740 C412 772 372 792 340 774 C313 761 305 735 309 707 C281 723 249 719 225 704 C201 689 199 662 213 635 C231 605 236 597 234 559 Z"/>
        <path class="fur" d="M111 347 C122 242 196 142 299 70 C342 40 380 25 402 46 C421 65 428 92 433 126 C481 130 514 153 546 174 C617 174 696 184 725 225 C751 261 724 315 687 363 C648 418 586 461 532 494 C470 533 398 564 324 561 C235 558 165 521 132 466 C110 429 104 387 111 347 Z"/>
        <path class="ear" d="M619 321 C655 294 690 281 722 278 C719 333 666 399 610 443 C618 396 621 355 619 321 Z"/>
        <path class="eye" d="M140 267 C125 296 115 337 119 380 C121 435 149 483 190 488 C229 493 264 457 285 416 L258 393 C238 430 214 445 188 429 C159 411 150 374 151 337 C151 319 156 300 165 286 Z"/>
        <path class="eye" d="M322 437 L371 424 C377 475 396 499 429 499 C479 501 513 459 524 414 C530 389 528 370 524 352 C555 381 568 425 561 466 C550 523 512 551 463 554 C389 558 340 517 322 437 Z"/>`,
    },
    rest: {
      transform: 'translate(-42 -35) scale(.85)',
      look: 10,
      art: `<path class="fur tail" d="M479 485 C528 504 561 540 587 588 C600 613 614 649 632 645 C658 638 642 593 623 559 C598 515 561 475 527 457 Z"/>
        <path class="fur" d="M302 284 C354 265 417 297 461 322 C498 344 532 364 555 371 C574 337 597 322 621 335 C648 350 640 383 620 409 L565 473 C548 493 527 505 497 505 C481 544 451 564 425 548 C405 536 400 516 389 501 C354 474 328 433 312 405 C284 420 258 415 245 399 C230 379 251 354 279 345 Z"/>
        <path class="fur" d="M117 285 C128 222 172 161 227 141 C279 121 341 133 378 168 C398 187 408 212 411 237 C428 225 444 231 449 246 C456 264 445 282 438 293 C456 321 458 344 435 363 C404 387 360 383 318 386 L184 413 C159 418 138 408 139 391 C141 374 159 367 174 364 C150 375 126 383 113 373 C101 364 110 338 117 321 L108 318 Z"/>
        <path class="ear" d="M111 347 C124 337 137 338 151 345 L172 362 C147 373 128 380 114 373 C108 369 107 358 111 347 Z"/>
        <g class="blink"><ellipse class="eye" cx="195" cy="245" rx="54" ry="68" transform="rotate(24 195 245)"/><ellipse class="eye" cx="320" cy="184" rx="66" ry="48" transform="rotate(32 320 184)"/>
        <g class="look"><g class="pupils"><ellipse cx="202" cy="244" rx="39" ry="49" transform="rotate(24 202 244)"/><ellipse cx="325" cy="185" rx="46" ry="34" transform="rotate(32 325 185)"/></g></g></g>
        <path d="M305 283 Q309 275 316 272" fill="none" stroke="#fff" stroke-width="5" stroke-linecap="round"/>`,
    },
    // Traced from the footer artwork supplied for the site (622 x 604).
    peek: {
      viewBox: '85 62 467 534',
      transform: 'translate(0 0)',
      look: 12,
      art: `<path class="fur" d="M303 62 L331 62 L351 68 L353 70 L358 68 L366 68 L369 75 L369 82 L378 92 L382 100 L386 116 L385 129 L387 131 L420 123 L453 119 L505 118 L524 120 L537 124 L545 131 L549 140 L552 161 L552 198 L549 233 L539 266 L536 283 L527 312 L524 317 L524 334 L520 353 L515 370 L506 390 L495 408 L480 423 L464 435 L423 453 L390 461 L408 490 L424 527 L432 555 L438 596 L332 595 L204 594 L208 558 L218 524 L236 484 L252 461 L247 458 L230 456 L210 451 L172 436 L156 426 L139 408 L124 383 L115 359 L111 343 L108 312 L96 276 L85 212 L85 161 L87 141 L91 130 L99 120 L116 115 L165 116 L211 120 L248 128 L251 102 L258 89 L265 82 L265 71 L267 69 L279 71 L283 68 L302 63Z"/>
        <path class="ear" d="M97 132 L100 132 L113 139 L137 156 L153 171 L158 178 L158 180 L141 200 L125 227 L116 247 L108 277 L107 286 L106 287 L104 282 L96 251 L90 212 L89 171 L90 158 L96 133Z"/><path class="ear" d="M539 138 L542 138 L545 143 L547 157 L548 194 L545 226 L539 254 L527 291 L526 293 L525 292 L525 285 L521 265 L509 233 L495 208 L482 191 L477 187 L477 185 L490 169 L510 153 L523 145 L538 139Z"/>
        <path class="eye" d="M281 84 L294 84 L303 89 L311 101 L314 112 L313 127 L308 138 L300 147 L293 150 L282 151 L273 147 L265 138 L260 125 L260 111 L263 102 L271 90 L280 85Z"/><path class="eye" d="M343 85 L353 87 L361 92 L368 101 L373 114 L373 131 L368 143 L361 150 L352 152 L342 151 L333 145 L328 139 L322 125 L322 106 L325 98 L332 89 L342 86Z"/><g class="pupils"><path d="M285 95 L291 95 L299 98 L307 108 L309 117 L308 126 L304 134 L300 138 L291 142 L278 140 L271 134 L267 126 L266 118 L270 105 L277 98 L284 96Z"/><path d="M346 96 L352 96 L359 99 L365 105 L369 115 L369 122 L365 132 L360 138 L351 141 L343 141 L337 138 L332 133 L328 123 L328 116 L332 105 L338 99 L345 97Z"/></g>
        <g class="blink"><path class="eye" d="M218 168 L235 169 L255 176 L276 191 L290 208 L299 224 L308 250 L311 271 L311 305 L308 325 L299 353 L290 371 L278 388 L262 404 L244 416 L225 423 L214 424 L203 425 L181 420 L163 410 L147 395 L134 375 L124 352 L118 320 L118 291 L121 271 L129 244 L142 218 L151 206 L164 192 L182 179 L200 171 L217 169Z"/><path class="eye" d="M404 171 L420 171 L442 177 L460 187 L476 201 L494 225 L503 243 L511 267 L515 289 L515 325 L513 336 L508 356 L497 380 L485 396 L472 408 L451 419 L436 422 L421 423 L397 417 L377 405 L358 387 L345 368 L333 342 L327 320 L324 301 L324 275 L327 255 L333 234 L346 209 L363 190 L374 182 L388 175 L403 172Z"/><g class="look"><g class="pupils"><path d="M212 204 L223 205 L238 211 L256 227 L268 247 L274 266 L277 290 L275 315 L271 331 L264 347 L257 358 L244 371 L235 377 L223 381 L213 382 L198 380 L191 377 L176 366 L169 358 L156 334 L150 306 L151 272 L156 253 L164 236 L172 225 L181 216 L190 210 L203 205 L211 205Z"/><path d="M413 206 L427 206 L445 212 L454 218 L464 228 L478 250 L485 270 L487 281 L487 315 L485 326 L476 349 L463 366 L455 372 L444 378 L434 380 L420 380 L409 377 L389 364 L376 348 L371 339 L361 309 L361 267 L370 240 L379 226 L388 217 L402 209 L412 207Z"/></g></g></g>
        <path class="eye" d="M311 439 L336 440 L335 442 L311 443 L309 441 L310 440Z"/>`,
    },
    icon: {
      viewBox: '28 3 470 470',
      transform: 'translate(-30 -18) scale(.88)',
      look: 20,
      art: `<path class="fur" d="M175 263 C169 283 150 298 137 320 C106 370 119 430 160 471 C188 499 220 512 271 512 L420 512 C478 512 516 493 537 458 C561 420 556 376 545 340 L569 185 C574 156 552 141 530 157 L421 235 C415 240 409 242 399 242 L367 242 C353 242 346 239 338 229 L218 88 C205 72 180 68 174 91 L171 150 C169 164 173 171 189 179 C197 185 187 190 178 194 C166 201 166 210 179 216 C188 220 187 227 178 232 Z"/>
        <path class="whiskers" d="M98 422 L82 428 M107 459 L71 481 M572 422 L587 429 M556 461 L594 486" fill="none" stroke-width="20" stroke-linecap="round"/>
        <g class="blink"><ellipse class="eye" cx="232" cy="365" rx="77" ry="87"/><ellipse class="eye" cx="443" cy="367" rx="77" ry="87"/>
        <g class="look"><g class="pupils"><ellipse cx="255" cy="368" rx="30" ry="49"/><ellipse cx="418" cy="369" rx="30" ry="49"/></g></g></g>`,
    },
  };

  function mountCats() {
    for (const host of $$('[data-cat]')) {
      const pose = POSES[host.dataset.cat];
      host.classList.add('cat-host');
      host.innerHTML = `<svg class="cat cat-${host.dataset.cat}" viewBox="${pose.viewBox || '0 0 512 512'}" data-look="${pose.look}" aria-hidden="true" focusable="false"><g transform="${pose.transform}"><g class="breathe">${pose.art}</g></g></svg>`;
    }
  }

  /** Plays a one-shot reaction class (is-petted, is-happy) on a cat host. */
  function react(host, name) {
    if (!host) return;
    host.classList.remove(name);
    void host.offsetWidth;
    host.classList.add(name);
    host.addEventListener('animationend', () => host.classList.remove(name), { once: true });
  }

  /** Visible cats glance toward the mouse pointer. */
  function setupGaze() {
    const watching = new Set();
    const io = new IntersectionObserver((entries) => {
      for (const entry of entries) entry.isIntersecting ? watching.add(entry.target) : watching.delete(entry.target);
    });
    for (const svg of $$('.cat')) if (+svg.dataset.look) io.observe(svg);

    let pointer = null;
    let frame = 0;
    const update = () => {
      frame = 0;
      for (const svg of watching) {
        const look = $('.look', svg);
        if (!pointer || isStill()) { look.style.transform = ''; continue; }
        const box = svg.getBoundingClientRect();
        if (!box.width) continue;
        const dx = pointer.x - (box.left + box.width / 2);
        const dy = pointer.y - (box.top + box.height * 0.45);
        const distance = Math.hypot(dx, dy) || 1;
        const reach = Math.min(1, distance / 240) * +svg.dataset.look;
        look.style.transform = `translate(${(dx / distance) * reach}px, ${(dy / distance) * reach * 0.8}px)`;
      }
    };
    const request = () => { if (!frame) frame = requestAnimationFrame(update); };
    addEventListener('pointermove', (event) => {
      if (event.pointerType !== 'mouse') return;
      pointer = { x: event.clientX, y: event.clientY };
      request();
    }, { passive: true });
    addEventListener('scroll', request, { passive: true });
    document.addEventListener('mouseleave', () => { pointer = null; request(); });
  }

  /* Rolling digits ------------------------------------------------------------ */

  /**
   * Shows `text` in `el`, sliding changed digits through their slots like
   * SwiftUI's numericText transition. dir 1 counts down, -1 counts up.
   */
  function setDigits(el, text, { dir = 1, duration = 260 } = {}) {
    const shape = text.replace(/\d/g, '0');
    if (el.dataset.shape !== shape) {
      el.dataset.shape = shape;
      el.innerHTML = [...text].map((c) => (/\d/.test(c) ? `<span class="slot" aria-hidden="true"><span>${c}</span></span>` : `<span class="colon" aria-hidden="true">${c}</span>`)).join('');
      return;
    }
    [...text].forEach((char, i) => {
      const slot = el.children[i];
      const current = slot.lastElementChild;
      if (!slot.classList.contains('slot') || current.textContent === char) return;
      // Drop digits still sliding out from earlier updates; background tabs pause
      // animations, and the old digits would otherwise pile up.
      while (slot.childElementCount > 1) slot.firstElementChild.remove();
      const next = document.createElement('span');
      next.textContent = char;
      slot.append(next);
      if (isStill() || duration === 0 || document.hidden) { current.remove(); return; }
      const shift = `${70 * dir}%`;
      const options = { duration, easing: EASE };
      current.animate([{ transform: 'none', opacity: 1, filter: 'blur(0)' }, { transform: `translateY(${shift})`, opacity: 0, filter: 'blur(2px)' }], options)
        .finished.finally(() => current.remove()).catch(() => {});
      next.animate([{ transform: `translateY(calc(${shift} * -1))`, opacity: 0, filter: 'blur(2px)' }, { transform: 'none', opacity: 1, filter: 'blur(0)' }], options);
    });
  }

  /* Hero: a working copy of the Milo panel ------------------------------------- */
  // Mirrors MiloCore/SessionEngine.swift: remaining time is derived from a
  // deadline, a finished focus session counts once, and Start after a
  // completed session begins whatever comes next.

  const KINDS = {
    focus: { title: 'Focus', minutes: 25 },
    short: { title: 'Short break', minutes: 5 },
    long: { title: 'Long break', minutes: 15 },
  };

  function setupDemo() {
    const panel = $('[data-panel]');
    const clock = $('[data-clock-face]');
    const primary = $('[data-primary]');
    const primaryLabel = $('[data-primary-label]');
    const status = $('[data-status]');
    const ff = $('[data-ff]');
    const todayCount = $('[data-today-count]');
    const modes = $('[data-modes]');
    const lines = $('[data-lines]');
    const state = { kind: 'focus', phase: 'ready', remaining: 25 * 60, deadline: 0, done: 0, sinceLong: 0, every: 4, goal: 4 };
    let ticker = 0;
    let fastForward = null;
    let typing = 0;

    const now = () => performance.now();
    const secondsLeft = () => (state.phase === 'running' ? Math.max(0, (state.deadline - now()) / 1000) : state.remaining);
    const countdown = (seconds) => {
      const s = Math.max(0, Math.ceil(seconds));
      return `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
    };
    const nextKind = () => (state.kind !== 'focus' ? 'focus' : state.sinceLong >= state.every ? 'long' : 'short');
    const pose = () => (state.phase === 'completed' ? 'idle' : state.kind !== 'focus' ? 'rest' : state.phase === 'running' ? 'focus' : 'idle');
    const statusText = () => ({
      completed: state.kind === 'focus' ? 'One session closer. Well done.' : 'Rested? Milo is ready when you are.',
      paused: 'Take your time. Milo’s here.',
      running: state.kind === 'focus' ? 'Quiet company. You’ve got this.' : 'Stretch. Breathe. Take your time.',
      ready: state.kind === 'focus' ? 'A little focus. Together.' : 'A little rest does you good.',
    })[state.phase];
    const primaryTitle = () => {
      if (state.phase === 'running') return 'Pause';
      if (state.phase === 'paused') return 'Resume';
      const kind = state.phase === 'completed' ? nextKind() : state.kind;
      if (kind === 'focus') return 'Start focus';
      return state.phase === 'completed' ? `Start ${KINDS[kind].title.toLowerCase()}` : 'Start break';
    };

    function moveThumb() {
      const selected = $(`[data-mode="${state.kind}"]`, modes);
      const thumb = $('.modes-thumb', modes);
      thumb.style.setProperty('--tx', `${selected.offsetLeft}px`);
      thumb.style.setProperty('--tw', `${selected.offsetWidth}px`);
    }

    function render({ fast = false } = {}) {
      const text = countdown(secondsLeft());
      setDigits(clock, text, { dir: 1, duration: fast ? 110 : 260 });
      clock.setAttribute('aria-label', `${text} remaining`);
      primaryLabel.textContent = primaryTitle();
      primary.classList.toggle('is-running', state.phase === 'running');
      for (const button of $$('[data-mode]', modes)) {
        const on = button.dataset.mode === state.kind;
        button.setAttribute('aria-checked', String(on));
        button.tabIndex = on ? 0 : -1;
      }
      moveThumb();
      for (const host of $$('[data-pose]', panel)) host.classList.toggle('is-on', host.dataset.pose === pose());
      ff.hidden = state.phase !== 'running';
      const message = statusText();
      if (status.textContent !== message) {
        status.classList.add('is-swapping');
        setTimeout(() => { status.textContent = message; status.classList.remove('is-swapping'); }, isStill() ? 0 : 200);
      }
    }

    function setTyping(on) {
      clearInterval(typing);
      if (!on) return;
      typing = setInterval(() => {
        if (lines.children.length >= 9) return clearInterval(typing);
        const line = document.createElement('i');
        line.className = 'is-new';
        line.style.setProperty('--w', `${55 + Math.round(Math.random() * 40)}%`);
        lines.append(line);
      }, 2600);
    }

    function schedule() {
      clearInterval(ticker);
      setTyping(state.phase === 'running' && state.kind === 'focus');
      if (state.phase !== 'running') return;
      ticker = setInterval(() => { if (!fastForward) tick(); }, 250);
    }

    function tick() {
      if (state.phase === 'running' && secondsLeft() <= 0) complete();
      else render();
    }

    function select(kind) {
      fastForward = null;
      Object.assign(state, { kind, phase: 'ready', remaining: KINDS[kind].minutes * 60, deadline: 0 });
      schedule();
      render();
    }

    function complete() {
      fastForward = null;
      const finished = state.kind;
      Object.assign(state, { phase: 'completed', remaining: 0, deadline: 0 });
      if (finished === 'focus') {
        state.done += 1;
        state.sinceLong += 1;
        setDigits(todayCount, String(state.done), { dir: -1 });
        $('[data-today-sr]').textContent = `${state.done} of ${state.goal} focus sessions completed today`;
      } else if (finished === 'long') {
        state.sinceLong = 0;
      }
      schedule();
      render();
      react($('[data-pose="idle"]', panel), 'is-happy');
      notify(finished === 'focus'
        ? ['Time for a little rest.', 'You finished a focus session. Milo is ready for a break with you.']
        : ['Ready for a little focus?', 'Your break is complete. Milo is here when you’re ready.']);
    }

    function startOrPause() {
      fastForward = null;
      if (state.phase === 'running') {
        if (secondsLeft() <= 0) return complete();
        Object.assign(state, { phase: 'paused', remaining: secondsLeft(), deadline: 0 });
      } else {
        if (state.phase === 'completed') select(nextKind());
        Object.assign(state, { phase: 'running', deadline: now() + state.remaining * 1000 });
      }
      schedule();
      render();
    }

    // Skips the demo forward, easing the remaining time down to zero.
    function skipToEnd() {
      if (state.phase !== 'running') return;
      if (isStill() || document.hidden) return complete();
      const from = secondsLeft();
      const started = now();
      let last = 0;
      // Any other action clears fastForward, which retires this run.
      const run = (fastForward = {});
      const step = () => {
        if (fastForward !== run) return;
        const t = Math.min(1, (now() - started) / 1500);
        const left = from * (1 - (1 - (1 - t) ** 3));
        state.deadline = now() + left * 1000;
        if (t >= 1) return complete();
        if (now() - last > 45) { last = now(); render({ fast: true }); }
        requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
    }

    const note = $('[data-note]');
    let noteTimer = 0;
    function notify([title, body]) {
      $('[data-note-title]').textContent = title;
      $('[data-note-body]').textContent = body;
      note.classList.remove('is-leaving');
      note.hidden = false;
      clearTimeout(noteTimer);
      noteTimer = setTimeout(dismissNote, 5200);
    }
    function dismissNote() {
      if (note.hidden) return;
      note.classList.add('is-leaving');
      setTimeout(() => { note.hidden = true; note.classList.remove('is-leaving'); }, isStill() ? 0 : 300);
    }
    note.addEventListener('click', dismissNote);

    primary.addEventListener('click', startOrPause);
    $('[data-reset]').addEventListener('click', () => select(state.kind));
    ff.addEventListener('click', skipToEnd);
    radioGroup(modes, '[data-mode]', (button) => {
      if (button.dataset.mode !== state.kind) select(button.dataset.mode);
    });
    $('[data-pet]', panel).addEventListener('click', () => react($('.pose.is-on', panel), 'is-petted'));

    const menubarCat = $('[data-menubar-cat]');
    menubarCat.addEventListener('click', () => togglePanel(panel, menubarCat));
    panel.addEventListener('keydown', (event) => {
      if (event.key !== 'Escape') return;
      togglePanel(panel, menubarCat, false);
      menubarCat.focus();
    });

    document.addEventListener('visibilitychange', () => { if (!document.hidden) tick(); });
    addEventListener('resize', moveThumb);
    document.fonts?.ready.then(moveThumb);
    setDigits(todayCount, '0');
    render();
  }

  /** Opens or closes a panel from its menu bar icon with the genie animation. */
  function togglePanel(panel, button, open = !panel.classList.contains('is-open')) {
    button.setAttribute('aria-expanded', String(open));
    panel.classList.remove('is-opening', 'is-closing');
    void panel.offsetWidth;
    panel.classList.toggle('is-open', open);
    panel.classList.add(open ? 'is-opening' : 'is-closing');
    const done = (event) => {
      if (event.target !== panel) return;
      panel.classList.remove('is-opening', 'is-closing');
      panel.removeEventListener('animationend', done);
    };
    panel.addEventListener('animationend', done);
  }

  /** Radio-group behavior: click to choose, arrow keys to move, one tab stop. */
  function radioGroup(group, selector, onChoose) {
    group.addEventListener('click', (event) => {
      const button = event.target.closest(selector);
      if (button) onChoose(button);
    });
    group.addEventListener('keydown', (event) => {
      const step = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[event.key];
      if (!step) return;
      event.preventDefault();
      const buttons = $$(selector, group);
      const index = buttons.indexOf(document.activeElement);
      const next = buttons[(index + step + buttons.length) % buttons.length];
      next.focus();
      onChoose(next);
    });
  }

  /* Rhythm: one Pomodoro round as a route ------------------------------------- */

  const RHYTHMS = {
    sprints: { focus: 25, short: 5, long: 15, every: 4 },
    deep: { focus: 50, short: 10, long: 30, every: 3 },
    gentle: { focus: 15, short: 3, long: 10, every: 4 },
  };
  const BREAK_NOTES = ['Stretch', 'Refill', 'Look away'];

  function buildRound({ focus, short, long, every }) {
    const stops = [];
    for (let session = 1; session <= every; session += 1) {
      stops.push({ kind: 'focus', name: 'Focus', minutes: focus, meta: `Session ${session}` });
      stops.push(session < every
        ? { kind: 'short', name: 'Short break', minutes: short, meta: BREAK_NOTES[(session - 1) % BREAK_NOTES.length] }
        : { kind: 'long', name: 'Long break', minutes: long, meta: 'Earned' });
    }
    return stops;
  }

  function setupRhythm() {
    const list = $('[data-stops]');
    const bar = $('[data-timebar]');
    const summary = $('[data-round-sum]');
    const picker = $('[data-picker]');
    const maxStops = Math.max(...Object.values(RHYTHMS).map((r) => r.every * 2));
    bar.innerHTML = '<i></i>'.repeat(maxStops);
    let stops = [];
    let here = 0;

    const labelFor = (i) => (i === here ? 'You are here' : i < here ? 'Done' : i === stops.length - 1 ? 'Finally' : i === here + 1 ? 'Next' : 'Then');

    function mark() {
      list.style.setProperty('--a', here);
      $$('.stop', list).forEach((li, i) => {
        li.classList.toggle('is-here', i === here);
        li.classList.toggle('is-past', i < here);
        $('.stop-label', li).textContent = labelFor(i);
        const button = $('.stop-card', li);
        if (i === here) button.setAttribute('aria-current', 'step');
        else button.removeAttribute('aria-current');
      });
    }

    function draw(rhythm) {
      stops = buildRound(rhythm);
      here = Math.min(here, stops.length - 1);
      list.style.setProperty('--n', stops.length);
      list.innerHTML = stops.map((stop, i) => `
        <li class="stop" data-kind="${stop.kind}" style="--i:${i}">
          <button class="stop-card" type="button">
            <span class="stop-label"></span>
            <span class="stop-num">${[...String(stop.minutes)].map((d, j) => `<span class="slot" style="--j:${j}"><span>${d}</span></span>`).join('')} <small>min</small></span>
            <span class="stop-name">${stop.name}</span>
            <span class="stop-meta">${stop.meta}</span>
          </button>
        </li>`).join('');
      mark();
      if (!isStill()) {
        for (const span of $$('.slot > span', list)) {
          const i = +span.closest('.stop').style.getPropertyValue('--i');
          const j = +span.parentElement.style.getPropertyValue('--j');
          span.animate([{ transform: 'translateY(70%)', opacity: 0, filter: 'blur(2px)' }, { transform: 'none', opacity: 1, filter: 'blur(0)' }],
            { duration: 520, delay: 160 + i * 45 + j * 50, easing: EASE, fill: 'backwards' });
        }
      }
      [...bar.children].forEach((segment, i) => {
        const stop = stops[i];
        segment.dataset.kind = stop ? stop.kind : 'none';
        segment.style.flexGrow = stop ? stop.minutes : 0;
      });
      const total = stops.reduce((sum, stop) => sum + stop.minutes, 0);
      const time = `${Math.floor(total / 60)} h ${String(total % 60).padStart(2, '0')} min`.replace(' 00 min', '');
      summary.classList.add('is-swapping');
      setTimeout(() => {
        summary.textContent = `One round · ${time} · ${rhythm.every} focus sessions`;
        summary.classList.remove('is-swapping');
      }, isStill() ? 0 : 220);
    }

    let leaving = 0;
    function choose(button) {
      for (const option of $$('[data-rhythm]', picker)) {
        const on = option === button;
        option.setAttribute('aria-checked', String(on));
        option.tabIndex = on ? 0 : -1;
      }
      const rhythm = RHYTHMS[button.dataset.rhythm];
      clearTimeout(leaving);
      if (isStill()) return draw(rhythm);
      list.classList.add('is-leaving');
      leaving = setTimeout(() => { list.classList.remove('is-leaving'); draw(rhythm); }, 240 + stops.length * 22);
    }

    radioGroup(picker, '[data-rhythm]', (button) => {
      if (button.getAttribute('aria-checked') !== 'true') choose(button);
    });
    list.addEventListener('click', (event) => {
      const li = event.target.closest('.stop');
      if (!li) return;
      here = $$('.stop', list).indexOf(li);
      mark();
    });
    $$('[data-rhythm]', picker).forEach((option, i) => { option.tabIndex = i === 0 ? 0 : -1; });
    draw(RHYTHMS.sprints);
  }

  /* Numbers that count into place ------------------------------------------------ */

  function countUp(el) {
    const to = parseFloat(el.dataset.count);
    const from = parseFloat(el.dataset.from ?? '0');
    const decimals = +(el.dataset.decimals ?? 0);
    const steps = Math.min(18, Math.round(Math.abs(to - from) * 10 ** decimals));
    const dir = to < from ? 1 : -1;
    const digits = String(Math.round(Math.max(from, to))).length;
    const format = (value) => value.toFixed(decimals).padStart(digits + (decimals ? decimals + 1 : 0), '0');
    setDigits(el, format(from));
    if (isStill() || steps === 0) return setDigits(el, format(to));
    let k = 0;
    const next = () => {
      k += 1;
      const eased = 1 - (1 - k / steps) ** 2;
      setDigits(el, format(from + (to - from) * eased), { dir, duration: 220 });
      if (k < steps) setTimeout(next, 45 + 220 * (k / steps) ** 3);
    };
    setTimeout(next, 250);
  }

  /* The idea: words fill in with scroll -------------------------------------------- */

  function setupScrub() {
    const block = $('[data-scrub]');
    let count = 0;
    const split = (node) => {
      for (const child of [...node.childNodes]) {
        if (child.nodeType === Node.ELEMENT_NODE) { split(child); continue; }
        if (child.nodeType !== Node.TEXT_NODE) continue;
        const fragment = document.createDocumentFragment();
        for (const part of child.textContent.split(/(\s+)/)) {
          if (!part) continue;
          if (/^\s+$/.test(part)) { fragment.append(part); continue; }
          const word = document.createElement('span');
          word.className = 'w';
          word.style.setProperty('--i', count++);
          word.textContent = part;
          fragment.append(word);
        }
        child.replaceWith(fragment);
      }
    };
    split(block);
    block.style.setProperty('--n', count);
    let frame = 0;
    const update = () => {
      frame = 0;
      if (reduceMotion.matches) return block.style.setProperty('--p', 1);
      const box = block.getBoundingClientRect();
      const progress = (innerHeight * 0.88 - box.top) / (box.height + innerHeight * 0.4);
      block.style.setProperty('--p', Math.min(1, Math.max(0, progress)).toFixed(3));
    };
    addEventListener('scroll', () => { if (!frame) frame = requestAnimationFrame(update); }, { passive: true });
    addEventListener('resize', update);
    update();
  }

  /* Reveals, toggles and small details ---------------------------------------------- */

  function setupReveals() {
    const io = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        entry.target.classList.add('in');
        if (entry.target.matches('.stats')) $$('[data-count]', entry.target).forEach(countUp);
        io.unobserve(entry.target);
      }
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.1 });
    $$('.reveal, .flip').forEach((el) => io.observe(el));

    // The peeking cat hides behind the footer, so watch its section instead.
    const peek = $('[data-peek]');
    new IntersectionObserver(([entry], observer) => {
      if (!entry.isIntersecting) return;
      peek.classList.add('in');
      observer.disconnect();
    }, { threshold: 0.45 }).observe($('#get'));
  }

  function setupAnimateToggle() {
    const toggle = $('[data-animate-toggle]');
    const note = $('[data-animate-note]');
    const KEY = 'milo.animate';
    // Remembered per visitor, so turning motion off sticks between visits.
    const wantsMotion = () => { try { return localStorage.getItem(KEY) !== 'off'; } catch { return true; } };
    const apply = () => {
      root.classList.toggle('still', !toggle.checked);
      if (reduceMotion.matches) note.textContent = 'Reduce Motion is on, so Milo is already sitting still.';
      else note.textContent = toggle.checked ? 'Every cat on this page is listening.' : 'Milo is sitting still. So is every cat on this page.';
    };
    const sync = () => {
      toggle.disabled = reduceMotion.matches;
      toggle.checked = !reduceMotion.matches && wantsMotion();
      apply();
    };
    toggle.addEventListener('change', () => {
      try { localStorage.setItem(KEY, toggle.checked ? 'on' : 'off'); } catch { /* storage unavailable */ }
      apply();
    });
    reduceMotion.addEventListener('change', sync);
    sync();
  }

  function setupMiniPanel() {
    const button = $('[data-mini-cat]');
    const panel = $('[data-mini-panel]');
    button.addEventListener('click', () => togglePanel(panel, button));
  }

  function setupPets() {
    for (const button of $$('.mood-art[data-pet]')) {
      button.addEventListener('click', () => react($('.cat-host', button), 'is-petted'));
    }
  }

  function setupNav() {
    const nav = $('[data-nav]');
    const update = () => nav.classList.toggle('is-scrolled', scrollY > 8);
    addEventListener('scroll', update, { passive: true });
    update();
  }

  /** Glass panes catch a highlight where the mouse is (see .mood-card::after). */
  function setupGlassSheen() {
    addEventListener('pointermove', (event) => {
      if (event.pointerType !== 'mouse') return;
      const pane = event.target.closest?.('.mood-card, .round, .tile');
      if (!pane) return;
      const box = pane.getBoundingClientRect();
      pane.style.setProperty('--mx', `${event.clientX - box.left}px`);
      pane.style.setProperty('--my', `${event.clientY - box.top}px`);
    }, { passive: true });
  }

  function setupClock() {
    const clock = $('[data-clock]');
    const format = new Intl.DateTimeFormat(undefined, { weekday: 'short', hour: 'numeric', minute: '2-digit' });
    const update = () => { clock.textContent = format.format(new Date()); };
    update();
    setInterval(update, 20000);
  }

  applyDownloadState();
  setupToast();
  mountCats();
  setupGaze();
  setupDemo();
  setupRhythm();
  setupScrub();
  setupReveals();
  setupAnimateToggle();
  setupMiniPanel();
  setupPets();
  setupNav();
  setupGlassSheen();
  setupClock();
})();

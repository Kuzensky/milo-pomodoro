"""Editable vector redraws of the user's Milo references. No embedded bitmaps."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets"
OUT.mkdir(exist_ok=True)

def path(id, d, fill="#090909", **attrs):
    attrs = ' '.join(f'{k.replace("_", "-")}="{v}"' for k, v in attrs.items())
    return f'<path id="{id}" d="{d}" fill="{fill}" {attrs}/>'

def svg(name, label, content, transform=None, defs=""):
    if transform:
        content = f'<g id="character" transform="{transform}">{content}</g>'
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" role="img" aria-labelledby="title-{name} desc-{name}">
<title id="title-{name}">{label}</title>
<desc id="desc-{name}">Editable vector redraw from the supplied reference. Separate named parts for animation. Transparent background.</desc>
{defs}
{content}
</svg>'''

icon_head = "M175 263 C169 283 150 298 137 320 C106 370 119 430 160 471 C188 499 220 512 271 512 L420 512 C478 512 516 493 537 458 C561 420 556 376 545 340 L569 185 C574 156 552 141 530 157 L421 235 C415 240 409 242 399 242 L367 242 C353 242 346 239 338 229 L218 88 C205 72 180 68 174 91 L171 150 C169 164 173 171 189 179 C197 185 187 190 178 194 C166 201 166 210 179 216 C188 220 187 227 178 232 Z"
icon = path("head", icon_head, "url(#milo-red)")
icon += '<g id="whiskers" stroke="url(#milo-red)" stroke-width="20" stroke-linecap="round" fill="none"><path d="M98 422 L82 428 M107 459 L71 481 M572 422 L587 429 M556 461 L594 486"/></g>'
icon += '<g id="eyes" fill="#fff"><ellipse id="eye-left" cx="232" cy="365" rx="77" ry="87"/><ellipse id="eye-right" cx="443" cy="367" rx="77" ry="87"/></g>'
icon += '<g id="pupils" fill="url(#milo-red)"><ellipse id="pupil-left" cx="255" cy="368" rx="30" ry="49"/><ellipse id="pupil-right" cx="418" cy="369" rx="30" ry="49"/></g>'
defs = '<defs><linearGradient id="milo-red" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#030303"/><stop offset=".5" stop-color="#080808"/><stop offset="1" stop-color="#111111"/></linearGradient></defs>'

idle_tail = "M568 552 C675 531 749 595 782 672 C818 756 788 846 711 889 C645 928 538 938 437 920 C384 917 349 902 367 857 C384 815 418 812 470 819 C554 830 625 817 672 786 C729 748 708 678 639 650 L583 634 Z"
idle_body = "M246 520 C298 481 415 484 491 501 C558 515 607 554 618 618 C622 690 563 757 480 772 L426 778 C410 813 366 831 334 808 C309 790 312 766 319 737 C286 761 245 752 216 736 C184 718 171 688 185 657 C200 625 223 613 220 572 Z"
idle_head = "M73 361 C89 237 170 122 275 46 C315 18 355 -2 381 11 C410 26 419 65 424 105 C469 115 505 144 540 166 C625 165 708 181 739 225 C770 263 738 329 704 378 C663 438 605 482 553 518 C487 565 397 596 309 591 C201 585 123 530 88 463 C73 435 65 396 73 361 Z"
idle_ear = "M625 312 C664 288 705 275 735 272 C734 332 672 402 613 444 C619 395 625 357 625 312 Z"
idle = path("tail", idle_tail) + path("body", idle_body) + path("head", idle_head) + path("ear-inner", idle_ear, "#fff")
idle += '<g id="eyes" fill="#fff"><ellipse id="eye-left" cx="177" cy="345" rx="101" ry="162" transform="rotate(9 177 345)"/><ellipse id="eye-right" cx="434" cy="411" rx="133" ry="160" transform="rotate(-9 434 411)"/></g>'
idle += '<g id="pupils" fill="#090909"><ellipse id="pupil-left" cx="185" cy="342" rx="65" ry="103" transform="rotate(9 185 342)"/><ellipse id="pupil-right" cx="441" cy="410" rx="85" ry="109" transform="rotate(-9 441 410)"/></g>'

focus_tail = "M558 535 C656 506 736 569 767 635 C789 680 783 741 760 751 C730 765 696 742 694 707 C691 658 664 641 620 636 L578 645 Z"
focus_body = "M262 498 C323 463 441 468 512 492 C580 514 609 568 610 623 C610 684 562 721 489 735 L427 740 C412 772 372 792 340 774 C313 761 305 735 309 707 C281 723 249 719 225 704 C201 689 199 662 213 635 C231 605 236 597 234 559 Z"
focus_head = "M111 347 C122 242 196 142 299 70 C342 40 380 25 402 46 C421 65 428 92 433 126 C481 130 514 153 546 174 C617 174 696 184 725 225 C751 261 724 315 687 363 C648 418 586 461 532 494 C470 533 398 564 324 561 C235 558 165 521 132 466 C110 429 104 387 111 347 Z"
focus_ear = "M619 321 C655 294 690 281 722 278 C719 333 666 399 610 443 C618 396 621 355 619 321 Z"
focus = path("tail", focus_tail) + path("body", focus_body) + path("head", focus_head) + path("ear-inner", focus_ear, "#fff")
focus += '<g id="eyes" fill="#fff">' + path("eye-left", "M140 267 C125 296 115 337 119 380 C121 435 149 483 190 488 C229 493 264 457 285 416 L258 393 C238 430 214 445 188 429 C159 411 150 374 151 337 C151 319 156 300 165 286 Z", "#fff") + path("eye-right", "M322 437 L371 424 C377 475 396 499 429 499 C479 501 513 459 524 414 C530 389 528 370 524 352 C555 381 568 425 561 466 C550 523 512 551 463 554 C389 558 340 517 322 437 Z", "#fff") + '</g>'

rest_tail = "M479 485 C528 504 561 540 587 588 C600 613 614 649 632 645 C658 638 642 593 623 559 C598 515 561 475 527 457 Z"
rest_body = "M302 284 C354 265 417 297 461 322 C498 344 532 364 555 371 C574 337 597 322 621 335 C648 350 640 383 620 409 L565 473 C548 493 527 505 497 505 C481 544 451 564 425 548 C405 536 400 516 389 501 C354 474 328 433 312 405 C284 420 258 415 245 399 C230 379 251 354 279 345 Z"
rest_head = "M117 285 C128 222 172 161 227 141 C279 121 341 133 378 168 C398 187 408 212 411 237 C428 225 444 231 449 246 C456 264 445 282 438 293 C456 321 458 344 435 363 C404 387 360 383 318 386 L184 413 C159 418 138 408 139 391 C141 374 159 367 174 364 C150 375 126 383 113 373 C101 364 110 338 117 321 L108 318 Z"
rest_ear = "M111 347 C124 337 137 338 151 345 L172 362 C147 373 128 380 114 373 C108 369 107 358 111 347 Z"
rest = path("tail", rest_tail) + path("body", rest_body) + path("head", rest_head) + path("ear-inner", rest_ear, "#fff")
rest += '<g id="eyes" fill="#fff"><ellipse id="eye-left" cx="195" cy="245" rx="54" ry="68" transform="rotate(24 195 245)"/><ellipse id="eye-right" cx="320" cy="184" rx="66" ry="48" transform="rotate(32 320 184)"/></g>'
rest += '<g id="pupils" fill="#090909"><ellipse id="pupil-left" cx="202" cy="244" rx="39" ry="49" transform="rotate(24 202 244)"/><ellipse id="pupil-right" cx="325" cy="185" rx="46" ry="34" transform="rotate(32 325 185)"/></g>'
rest += '<path id="mouth" d="M305 283 Q309 275 316 272" fill="none" stroke="#fff" stroke-width="5" stroke-linecap="round"/>'

files = {
    "milo-icon.svg": svg("icon", "Milo monochrome cat icon", icon, "translate(-30 -18) scale(.88)", defs),
    "milo-idle.svg": svg("idle", "Milo — curious and ready", idle, "translate(47 23) scale(.49)"),
    "milo-focus.svg": svg("focus", "Milo — quietly focused", focus, "translate(9 12) scale(.58)"),
    "milo-rest.svg": svg("rest", "Milo — taking a break", rest, "translate(-42 -35) scale(.85)"),
}

for name, content in files.items():
    ET.fromstring(content)
    (OUT / name).write_text(content + "\n")

manifest = {
    "version": 1,
    "viewBox": [0, 0, 512, 512],
    "source": "Vector redraws of user-supplied screenshots; not embedded raster images.",
    "files": {name: {"layers": [node.attrib["id"] for node in ET.fromstring(content).iter() if "id" in node.attrib]} for name, content in files.items()},
    "runtime": "Convert named SVG geometry into SwiftUI paths; animate native groups. SVG browser animation is preview-only.",
    "states": {
        "idle": {"asset": "milo-idle.svg", "loopSeconds": 4.8, "motion": "gentle breathing, slow tail sway, occasional blink"},
        "focus": {"asset": "milo-focus.svg", "loopSeconds": 6.0, "motion": "subtle breathing, sparse ear twitch"},
        "rest": {"asset": "milo-rest.svg", "loopSeconds": 5.2, "motion": "reclined breathing, soft tail tip movement"},
        "complete": {"asset": "milo-idle.svg", "loopSeconds": None, "motion": "one 600ms happy bounce, then settle"},
    },
    "accessibility": {"reducedMotion": "Static pose; no continuous motion or bounce", "darkAppearance": "Keep black character; add a softly lit neutral stage behind it"},
}
(OUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print("Wrote 4 SVG masters and animation manifest")

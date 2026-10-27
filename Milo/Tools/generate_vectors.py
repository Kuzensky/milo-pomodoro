"""Convert Milo's SVG masters into native SwiftUI paths. Standard library only."""
from pathlib import Path
import math
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
IDENTITY = (1, 0, 0, 1, 0, 0)

def mul(a, b):
    A, B, C, D, E, F = a
    g, h, i, j, k, l = b
    return (A*g+C*h, B*g+D*h, A*i+C*j, B*i+D*j, A*k+C*l+E, B*k+D*l+F)

def transform(value):
    result = IDENTITY
    for kind, data in re.findall(r'(\w+)\(([^)]+)\)', value or ''):
        n = [float(v) for v in re.findall(r'-?\d*\.?\d+', data)]
        if kind == 'translate':
            matrix = (1, 0, 0, 1, n[0], n[1] if len(n)>1 else 0)
        elif kind == 'scale':
            matrix = (n[0], 0, 0, n[1] if len(n)>1 else n[0], 0, 0)
        elif kind == 'rotate':
            c, s = math.cos(math.radians(n[0])), math.sin(math.radians(n[0]))
            matrix = (c, s, -s, c, 0, 0)
            if len(n) == 3:
                matrix = mul(mul((1,0,0,1,n[1],n[2]),matrix),(1,0,0,1,-n[1],-n[2]))
        else:
            raise ValueError(kind)
        result = mul(result, matrix)
    return result

def point(matrix, x, y):
    a,b,c,d,e,f = matrix
    return f'.init(x: {a*x+c*y+e:.3f}, y: {b*x+d*y+f:.3f})'

def commands(d, matrix):
    tokens = re.findall(r'[MLCQZmlcqz]|-?(?:\d*\.\d+|\d+)(?:e[-+]?\d+)?', d)
    out, pos, command = [], 0, None
    lengths = {'M':2,'L':2,'C':6,'Q':4,'Z':0}
    while pos < len(tokens):
        if tokens[pos].isalpha():
            command = tokens[pos]
            pos += 1
        if command not in lengths:
            raise ValueError(f'Unsupported path command: {command}')
        size = lengths[command]
        n = list(map(float, tokens[pos:pos+size]))
        pos += size
        if command == 'M':
            out.append(f'p.move(to: {point(matrix,*n)})')
            command = 'L'
        elif command == 'L': out.append(f'p.addLine(to: {point(matrix,*n)})')
        elif command == 'C':
            out.append(f'p.addCurve(to: {point(matrix,*n[4:])}, control1: {point(matrix,*n[:2])}, control2: {point(matrix,*n[2:4])})')
        elif command == 'Q':
            out.append(f'p.addQuadCurve(to: {point(matrix,*n[2:])}, control: {point(matrix,*n[:2])})')
        elif command == 'Z':
            out.append('p.closeSubpath()')
            command = None
    return out

def ellipse(node):
    x,y,rx,ry = [float(node.get(k)) for k in ('cx','cy','rx','ry')]
    k=.552284749831
    return f'M{x+rx} {y} C{x+rx} {y+k*ry} {x+k*rx} {y+ry} {x} {y+ry} C{x-k*rx} {y+ry} {x-rx} {y+k*ry} {x-rx} {y} C{x-rx} {y-k*ry} {x-k*rx} {y-ry} {x} {y-ry} C{x+k*rx} {y-ry} {x+rx} {y-k*ry} {x+rx} {y} Z'

def parts(node, matrix=IDENTITY, fill='#090909', stroke=None, width=0, group='body'):
    tag = node.tag.split('}')[-1]
    if tag in ('defs','title','desc','style'): return []
    matrix = mul(matrix, transform(node.get('transform')))
    fill = node.get('fill', fill)
    stroke = node.get('stroke', stroke)
    width = float(node.get('stroke-width', width))
    identifier = node.get('id', group)
    if identifier in ('eyes','pupils'): group='eyes'
    if tag in ('path','ellipse'):
        d = node.get('d') if tag == 'path' else ellipse(node)
        lines = commands(d, matrix)
        role = 'tail' if identifier=='tail' else ('eyes' if group=='eyes' else ('face' if identifier in ('head','ear-inner','mouth') else 'body'))
        color = stroke if fill == 'none' else fill
        is_white = color in ('#fff','#ffffff','white')
        stroke_width = width * math.hypot(matrix[0], matrix[1]) if fill=='none' else 0
        return [f'''        VectorPart(name: "{identifier}", path: Path {{ p in
            {(chr(10)+'            ').join(lines)}
        }}, white: {str(is_white).lower()}, stroke: {stroke_width:.3f}, role: .{role})''']
    result=[]
    for child in node:
        result.extend(parts(child,matrix,fill,stroke,width,group))
    return result

output = '''// Generated from Design/assets/*.svg by Tools/generate_vectors.py.
// Edit the SVG masters, then regenerate. No raster art or WebView is used.
import SwiftUI

enum VectorRole { case body, tail, face, eyes }
struct VectorPart {
    let name: String
    let path: Path
    let white: Bool
    let stroke: CGFloat
    let role: VectorRole
}
enum CatPose: String {
    case idle, focus, rest, icon
    var parts: [VectorPart] {
        switch self {
        case .idle: MiloVectors.idle
        case .focus: MiloVectors.focus
        case .rest: MiloVectors.rest
        case .icon: MiloVectors.icon
        }
    }
    var tailAnchor: CGPoint {
        switch self {
        case .idle: .init(x: 330, y: 315)
        case .focus: .init(x: 340, y: 340)
        case .rest: .init(x: 370, y: 390)
        case .icon: .zero
        }
    }
}
enum MiloVectors {
'''
for name in ('idle','focus','rest','icon'):
    root=ET.parse(ROOT/'Design'/'assets'/f'milo-{name}.svg').getroot()
    output += f'    static let {name}: [VectorPart] = [\n' + ',\n'.join(parts(root)) + '\n    ]\n'
output += '}\n'
destination=ROOT/'Sources'/'Milo'/'GeneratedVectors.swift'
destination.parent.mkdir(parents=True,exist_ok=True)
destination.write_text(output)
print(f'Generated native vectors: {destination}')

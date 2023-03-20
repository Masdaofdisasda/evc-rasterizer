%
% Copyright 2021 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

function linerasterization(mesh, framebuffer)
%LINERASTERIZATION iterates over all faces of mesh and draws lines between
%                  their vertices.
%     mesh                  ... mesh object to rasterize
%     framebuffer           ... framebuffer

for i = 1:numel(mesh.faces)
    for j = 1:mesh.faces(i)
        v1 = mesh.getFace(i).getVertex(j);
        v2 = mesh.getFace(i).getVertex(mod(j, mesh.faces(i))+1);
        drawLine(framebuffer, v1, v2);
    end
end
end

function drawLine(framebuffer, v1, v2)
%DRAWLINE draws a line between v1 and v2 into the framebuffer using the DDA
%         algorithm.
%         ATTENTION: Coordinates of the line have to be rounded with the
%         function 'round(...)'.
%     framebuffer           ... framebuffer
%     v1                    ... vertex 1
%     v2                    ... vertex 2

[x1, y1, depth1] = v1.getScreenCoordinates();
[x2, y2, depth2] = v2.getScreenCoordinates();

% absolute length
dx = abs(x2 - x1);
dy = abs(y2 - y1);
m = dy/dx;

signX = 1;
signY = 1;

if x1 > x2
    signX = -1;
end
if y1 > y2 
    signY = -1;
end


a = [x1, y1];
b = [x2, y2];
length = norm((b - a));

i = 1;

if m <= 1
    while i <= dx
        x = x1 + i * signX;
        y = y1 + i * m * signY;
        
        c = [x,y];
        distance = norm(b - c);
        t = abs(distance/length);
        color = MeshVertex.mix(v2.getColor(), v1.getColor(), t);
        depth = MeshVertex.mix(depth2, depth1, t);
        
        framebuffer.setPixel(round(x), round(y), depth, color);
        i = i + 1;
    end
else
    while i <= dy
        x = x1 + i/m * signX;
        y = y1 + i * signY;
        
        c = [x,y];
        distance = norm(b - c);
        t = abs(distance/length);
        color = MeshVertex.mix(v2.getColor(), v1.getColor(), t);
        depth = MeshVertex.mix(depth2, depth1, t);
        
        framebuffer.setPixel(round(x), round(y), depth, color);
        i = i + 1;
    end
end

end

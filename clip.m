%
% Copyright 2021 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

function [clipped_mesh] = clip(mesh, clipping_planes)
%CLIP clips all faces in the mesh M against every clipping plane defined in
%   clipplanes.
%     mesh              ... mesh object to clip
%     clipping_planes   ... array of clipping planes to clip against
%     clipped_mesh      ... clipped mesh

clipped_mesh = Mesh;

for f = 1:numel(mesh.faces)
    positions = mesh.getFace(f).getVertex(1:mesh.faces(f)).getPosition();
    colors = mesh.getFace(f).getVertex(1:mesh.faces(f)).getColor();
    vertex_count = 3;
    for i = 1:numel(clipping_planes)
        [vertex_count, positions, colors] = clipPlane(vertex_count, positions, colors, clipping_planes(i));
    end
    if vertex_count ~= 0
        clipped_mesh.addFace(vertex_count, positions, colors);
    end
end

end

function [vertex_count_clipped, pos_clipped, col_clipped] = clipPlane(vertex_count, positions, colors, clipping_plane)
%CLIPPLANE clips all vertices defined in positions against the clipping
%          plane clipping_plane. Clipping is done by using the Sutherland
%          Hodgman algorithm.
%     vertex_count          ... number of vertices of the face that is clipped
%     positions             ... n x 4 matrix with positions of n vertices
%                               one row corresponds to one vertex position
%     colors                ... n x 3 matrix with colors of n vertices
%                               one row corresponds to one vertex color
%     clipping_plane        ... plane to clip against
%     vertex_count_clipped  ... number of resulting vertices after clipping;
%                               this number depends on how the plane intersects
%                               with the face and therefore is not constant
%     pos_clipped           ... n x 4 matrix with positions of n clipped vertices
%                               one row corresponds to one vertex position
%     col_clipped           ... n x 3 matrix with colors of n clipped vertices
%                               one row corresponds to one vertex color

pos_clipped = zeros(1, 4);
col_clipped = zeros(1, 3);

% TODO 2:   Implement this function.
% HINT 1: 	Read the article about Sutherland Hodgman algorithm on Wikipedia.
%           https://en.wikipedia.org/wiki/Sutherland%E2%80%93Hodgman_algorithm
%           Read the tutorial.m for further explanations!
% HINT 2: 	There is an edge between every consecutive vertex in the positions
%       	matrix. Note: also between the last and first entry!


vertex_count_clipped = 0;

for i = 1:vertex_count
    if (i == 1)
        current = positions(1,:);
        previous = positions(vertex_count,:);
        curr_color = colors(1,:);
        prev_color = colors(vertex_count,:);
    else
        previous = current;
        current = positions(i,:);
        prev_color = curr_color;
        curr_color = colors(i,:);
    end
    
    if (inside(clipping_plane, current) == 1) %current inside
        
        if (inside(clipping_plane, previous) == 1) %previous inside
            pos_clipped = [pos_clipped; current];
            col_clipped = [col_clipped; curr_color];
            vertex_count_clipped = vertex_count_clipped + 1;
            
        else %previous outside
            vertex_count_clipped = vertex_count_clipped + 2;
            t = intersect(clipping_plane, previous, current);
            intersection = MeshVertex.mix(previous, current, t);
            pos_clipped = [pos_clipped; intersection];
            pos_clipped = [pos_clipped; current];
            
            intercolor = MeshVertex.mix(prev_color, curr_color, t);
            col_clipped = [col_clipped; intercolor];
            col_clipped = [col_clipped; curr_color];
        end
        
    else
        if (inside(clipping_plane, previous) == 1) %previous inside
            vertex_count_clipped = vertex_count_clipped + 1;
            t = intersect(clipping_plane, previous, current);
            intersection = MeshVertex.mix(previous, current, t);
            pos_clipped = [pos_clipped; intersection];
            
            intercolor = MeshVertex.mix(prev_color, curr_color, t);
            col_clipped = [col_clipped; intercolor];
        end
        
        % else add no vertex
    end
    
    %remove zeros
    if (size(pos_clipped,1) > 1 && pos_clipped(1,1) == 0 && pos_clipped(1,2) == 0 && pos_clipped(1,3) == 0 && pos_clipped(1,4) == 0 )
        pos_clipped(1,:) = [];
    end
    if (size(col_clipped,1) > 1 && col_clipped(1,1) == 0 && col_clipped(1,2) == 0 && col_clipped(1,3) == 0 )
        col_clipped(1,:) = [];
    end
end
end

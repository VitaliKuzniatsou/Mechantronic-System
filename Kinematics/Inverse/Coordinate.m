classdef Coordinate < matlab.System
    % Coordinate represents three coordinates: x, y, z

    properties(SetAccess = private)
        X
        Y
        Z
    end
    
    methods
        % Constructor
        function obj = Coordinate(x, y, z)
            obj.X = x;
            obj.Y = y;
            obj.Z = z;
        end
    end
end

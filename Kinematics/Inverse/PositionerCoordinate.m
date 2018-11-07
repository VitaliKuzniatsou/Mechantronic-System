classdef PositionerCoordinate < matlab.System
    % PositionerCoordinate is the wrapper over coordinate and driver
    % rectangle

    % Public, tunable properties
    properties(SetAccess = private)
        Coordinate
        DriverRectangle
    end

    methods
        % Constructor
        function obj = PositionerCoordinate(coordinate, driverWidth, driverHeight)
            if    isempty(coordinate.X) ...
               || isempty(coordinate.Y) ...
               || isempty(coordinate.Z)
                error("Some coordinates are not initialized")
            end
            
            obj.Coordinate = coordinate;
            obj.DriverRectangle = Rectangle(...
                Coordinate(coordinate.X - driverWidth/2 ...
                         , coordinate.Y - driverHeight/2 ...
                         , coordinate.Z)...
              , driverWidth ...
              , driverHeight);
        end
    end
end

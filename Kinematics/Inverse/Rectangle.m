classdef Rectangle < matlab.System
    % Rectangle represents a simple rectangle with four coordinates
    %

    % Public, tunable properties
    properties(SetAccess = private)
        InitialCoordinate
        Width
        Height
        CoordinateA
        CoordinateB
        CoordinateC
        CoordinateD
    end

    methods
        % Constructor
        function obj = Rectangle(initialCoordinate, width, height)
            if    isempty(initialCoordinate.X) ...
               || isempty(initialCoordinate.Y) ...
               || isempty(initialCoordinate.Z)
                error("Argument Error: initialCoordinate")
            end
            
            obj.InitialCoordinate = initialCoordinate;
            obj.Width = width;
            obj.Height = height;
            
            obj.calculateCoordinates();
        end
    end

    methods(Access = private)
        function calculateCoordinates(obj)
            if    isempty(obj.InitialCoordinate) ...
               || isempty(obj.Width) ...
               || isempty(obj.Height)
                error("Mistake in the development")
            end
            
            obj.CoordinateA = Coordinate(obj.InitialCoordinate.X ...
                                       , obj.InitialCoordinate.Y ...
                                       , obj.InitialCoordinate.Z);
            obj.CoordinateB = Coordinate(obj.InitialCoordinate.X + obj.Width ...
                                       , obj.InitialCoordinate.Y ...
                                       , obj.InitialCoordinate.Z);
            obj.CoordinateC = Coordinate(obj.InitialCoordinate.X + obj.Width ...
                                       , obj.InitialCoordinate.Y + obj.Height ...
                                       , obj.InitialCoordinate.Z);
            obj.CoordinateD = Coordinate(obj.InitialCoordinate.X ...
                                       , obj.InitialCoordinate.Y + obj.Height ...
                                       , obj.InitialCoordinate.Z);
        end
    end
end

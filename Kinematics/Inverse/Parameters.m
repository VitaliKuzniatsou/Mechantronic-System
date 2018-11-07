classdef Parameters < matlab.System
    % Parameters represents mechanism parameters

    % Public, tunable properties
    properties (SetAccess = private)
        Edge
        PositionerEdge
        StatorLine
        StatorRadius
        StatorThickness
    end

    methods
        % Constructor
        function obj = Parameters(edge ...
                                , positionerEdge ...
                                , statorLine ...
                                , statorRadius ...
                                , statorThickness)
            obj.Edge = edge;
            obj.PositionerEdge = positionerEdge;
            obj.StatorLine = statorLine;
            obj.StatorRadius = statorRadius;
            obj.StatorThickness = statorThickness;
        end
    end
end

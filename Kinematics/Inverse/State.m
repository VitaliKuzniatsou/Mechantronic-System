classdef State < matlab.System
    % State represents current coordinates, angles of the Mechanism

    properties(SetAccess = private)
        Dx
        Dy
        Dz
        Phi
        Theta
        Psi
    end
    
    properties(Access=private)
        OmegaD
        OmegaE
        OmegaF
    end
    
    properties(SetAccess = private)
        TransformMatrix
        CoordinateA
        CoordinateB
        CoordinateC
        PositionerCoordinateD
        PositionerCoordinateE
        PositionerCoordinateF
        Calculated
    end

    methods
        % Constructor
        function obj = State(dx ...
                           , dy ...
                           , dz ...
                           , phi ...
                           , theta ...
                           , psi)
            obj.Dx = dx;
            obj.Dy = dy;
            obj.Dz = dz;
            obj.Phi = phi;
            obj.Theta = theta;
            obj.Psi = psi;
            
            obj.Calculated = false;
        end
    end

    methods(Access = public)
        function calculate(obj, parameters)
            if    isempty(parameters.Edge) ...
               || isempty(parameters.PositionerEdge) ...
               || isempty(parameters.StatorLine) ...
               || isempty(parameters.StatorRadius) ...
               || isempty(parameters.StatorThickness)
                error("Some parameters are not initialized")
            end
            
            obj.calculateInternal(parameters);
        end
    end
    
    methods(Access = private)
        function calculateInternal(obj, parameters)
            %calculate transform matrix obj.TransformMatrix
            obj.TransformMatrix = ...
 [cosd(obj.Phi)*cosd(obj.Theta) ...
, -sind(obj.Phi)*cosd(obj.Psi)+cosd(obj.Phi)*sind(obj.Theta)*sind(obj.Psi) ...
, sind(obj.Phi)*sind(obj.Psi)+cosd(obj.Phi)*sind(obj.Theta)*cosd(obj.Psi) ...
, obj.Dx; ...
  sind(obj.Phi)*cosd(obj.Theta) ...
, cosd(obj.Phi)*cosd(obj.Psi)+sind(obj.Phi)*sind(obj.Theta)*sind(obj.Psi) ...
, -cosd(obj.Phi)*sind(obj.Psi)+sind(obj.Phi)*sind(obj.Theta)*cosd(obj.Psi) ...
, obj.Dy; ...
  -sind(obj.Theta) ...
, cosd(obj.Theta)*sind(obj.Psi) ...
, cosd(obj.Theta)*cosd(obj.Psi) ...
, obj.Dz; ...
  0 ...
, 0 ...
, 0 ...
, 1;];
             
            %calculate coordinates of work platform
            obj.CoordinateA = Coordinate(...
    obj.TransformMatrix(1, 4) + (parameters.Edge*obj.TransformMatrix(1, 1))/2 ...
  - (3^(1/2)*parameters.Edge*obj.TransformMatrix(1, 2))/6 ...
,   obj.TransformMatrix(2, 4) + (parameters.Edge*obj.TransformMatrix(2, 1))/2 ...
  - (3^(1/2)*parameters.Edge*obj.TransformMatrix(2, 2))/6 ...
,   obj.TransformMatrix(3, 4) + (parameters.Edge*obj.TransformMatrix(3, 1))/2 ...
  - (3^(1/2)*parameters.Edge*obj.TransformMatrix(3, 2))/6);
            obj.CoordinateB = Coordinate(...
    obj.TransformMatrix(1, 4) - (parameters.Edge*obj.TransformMatrix(1, 1))/2 ...
  - (3^(1/2)*parameters.Edge*obj.TransformMatrix(1, 2))/6 ...
,   obj.TransformMatrix(2, 4) - (parameters.Edge*obj.TransformMatrix(2, 1))/2 ...
  - (3^(1/2)*parameters.Edge*obj.TransformMatrix(2, 2))/6 ...
,   obj.TransformMatrix(3, 4) - (parameters.Edge*obj.TransformMatrix(3, 1))/2 ...
  - (3^(1/2)*parameters.Edge*obj.TransformMatrix(3, 2))/6);
            obj.CoordinateC = Coordinate(...
  obj.TransformMatrix(1, 4) + (3^(1/2)*parameters.Edge*obj.TransformMatrix(1, 2))/3 ...
, obj.TransformMatrix(2, 4) + (3^(1/2)*parameters.Edge*obj.TransformMatrix(2, 2))/3 ...
, obj.TransformMatrix(3, 4) + (3^(1/2)*parameters.Edge*obj.TransformMatrix(3, 2))/3);
            
            %calculate omegaD, omegaE, omegaF
            obj.calculateOmegaD(parameters)
            obj.calculateOmegaE(parameters)
            obj.calculateOmegaF(parameters)
            
            %calculate positioner coordinates of positioners
            obj.PositionerCoordinateD = PositionerCoordinate(Coordinate(...
  obj.TransformMatrix(1, 4) + (parameters.Edge*obj.TransformMatrix(1, 1))/4 ...
  + (3^(1/2)*parameters.Edge*obj.TransformMatrix(1, 2))/12 ...
  + (3^(1/2)*parameters.Edge*(cosd(obj.OmegaD)*(obj.TransformMatrix(1, 2)/2 ...
  + (3^(1/2)*obj.TransformMatrix(1, 1))/2) - obj.TransformMatrix(1, 3)*sind(obj.OmegaD)))/2 ...
,   obj.TransformMatrix(2, 4) + (parameters.Edge*obj.TransformMatrix(2, 1))/4 ...
  + (3^(1/2)*parameters.Edge*obj.TransformMatrix(2, 2))/12 ...
  + (3^(1/2)*parameters.Edge*(cosd(obj.OmegaD)*(obj.TransformMatrix(2, 2)/2 ...
  + (3^(1/2)*obj.TransformMatrix(2, 1))/2) - obj.TransformMatrix(2, 3)*sind(obj.OmegaD)))/2 ...
,   obj.TransformMatrix(3, 4) + (parameters.Edge*obj.TransformMatrix(3, 1))/4 ...
  + (3^(1/2)*parameters.Edge*obj.TransformMatrix(3, 2))/12 ...
  + (3^(1/2)*parameters.Edge*(cosd(obj.OmegaD)*(obj.TransformMatrix(3, 2)/2 ...
  + (3^(1/2)*obj.TransformMatrix(3, 1))/2) - obj.TransformMatrix(3, 3)*sind(obj.OmegaD)))/2) ...
            , parameters.PositionerEdge ...
            , parameters.PositionerEdge);
            obj.PositionerCoordinateE = PositionerCoordinate(Coordinate(...
    obj.TransformMatrix(1, 4) - (parameters.Edge*obj.TransformMatrix(1, 1))/4 ...
  + (3^(1/2)*parameters.Edge*obj.TransformMatrix(1, 2))/12 ...
  + (3^(1/2)*parameters.Edge*(cosd(obj.OmegaE)*(obj.TransformMatrix(1, 2)/2 ...
  - (3^(1/2)*obj.TransformMatrix(1, 1))/2) - obj.TransformMatrix(1, 3)*sind(obj.OmegaE)))/2 ...
,   obj.TransformMatrix(2, 4) - (parameters.Edge*obj.TransformMatrix(2, 1))/4 ...
  + (3^(1/2)*parameters.Edge*obj.TransformMatrix(2, 2))/12 ...
  + (3^(1/2)*parameters.Edge*(cosd(obj.OmegaE)*(obj.TransformMatrix(2, 2)/2 ...
  - (3^(1/2)*obj.TransformMatrix(2, 1))/2) - obj.TransformMatrix(2, 3)*sind(obj.OmegaE)))/2 ...
,   obj.TransformMatrix(3, 4) - (parameters.Edge*obj.TransformMatrix(3, 1))/4 ...
  + (3^(1/2)*parameters.Edge*obj.TransformMatrix(3, 2))/12 ...
  + (3^(1/2)*parameters.Edge*(cosd(obj.OmegaE)*(obj.TransformMatrix(3, 2)/2 ...
  - (3^(1/2)*obj.TransformMatrix(3, 1))/2) - obj.TransformMatrix(3, 3)*sind(obj.OmegaE)))/2) ...
            , parameters.PositionerEdge ...
            , parameters.PositionerEdge);
            obj.PositionerCoordinateF = PositionerCoordinate(Coordinate(...
    obj.TransformMatrix(1, 4) - (3^(1/2)*parameters.Edge*obj.TransformMatrix(1, 2))/6 ...
  - (3^(1/2)*parameters.Edge*(obj.TransformMatrix(1, 2)*cosd(obj.OmegaF) ...
  + obj.TransformMatrix(1, 3)*sind(obj.OmegaF)))/2 ...
,   obj.TransformMatrix(2, 4) - (3^(1/2)*parameters.Edge*obj.TransformMatrix(2, 2))/6 ...
  - (3^(1/2)*parameters.Edge*(obj.TransformMatrix(2, 2)*cosd(obj.OmegaF) ...
  + obj.TransformMatrix(2, 3)*sind(obj.OmegaF)))/2 ...
,   obj.TransformMatrix(3, 4) - (3^(1/2)*parameters.Edge*obj.TransformMatrix(3, 2))/6 ...
  - (3^(1/2)*parameters.Edge*(obj.TransformMatrix(3, 2)*cosd(obj.OmegaF) ...
  + obj.TransformMatrix(3, 3)*sind(obj.OmegaF)))/2) ...
            , parameters.PositionerEdge ...
            , parameters.PositionerEdge);
        
            obj.Calculated = true;
        end
        
        function calculateOmegaD(obj, parameters)
            if isempty(obj.TransformMatrix)
                error("Mistake in the development")
            end
            
            M =   3 * parameters.Edge * obj.TransformMatrix(3, 1) / 4 ...
                + sqrt(3) * parameters.Edge * obj.TransformMatrix(3, 2) / 4;
            N = -sqrt(3) * parameters.Edge * obj.TransformMatrix(3, 3) / 2;
            P =   parameters.Edge * obj.TransformMatrix(3, 1) / 4 ...
                + sqrt(3) * parameters.Edge * obj.TransformMatrix(3, 2) / 12 + obj.TransformMatrix(3, 4);

            q = M^2 + N^2;
            n = 2 * M * P;
            p = P^2 - N^2;

            obj.OmegaD = acosd((-n + sqrt(n^2 - 4 * q * p)) / (2 * q));
        end
        function calculateOmegaE(obj, parameters)
            if isempty(obj.TransformMatrix)
                error("Mistake in the development")
            end
            
            M =   -parameters.Edge * obj.TransformMatrix(3, 1) * 3/4 ...
                + parameters.Edge * obj.TransformMatrix(3, 2) * sqrt(3)/4;
            N = -parameters.Edge * obj.TransformMatrix(3, 3) * sqrt(3)/2;
            P =   -parameters.Edge * obj.TransformMatrix(3, 1) / 4 ...
                + parameters.Edge * obj.TransformMatrix(3, 2) * sqrt(3) / 12 + obj.TransformMatrix(3, 4);

            q = M^2 + N^2;
            n = 2 * M * P;
            p = P^2 - N^2;

            obj.OmegaE = acosd((-n + sqrt(n^2 - 4 * q * p)) / (2 * q));
        end
        function calculateOmegaF(obj, parameters)
            if isempty(obj.TransformMatrix)
                error("Mistake in the development")
            end
            
            M = obj.TransformMatrix(3, 2) * parameters.Edge * sqrt(3) / 2;
            N = obj.TransformMatrix(3, 3) * parameters.Edge * sqrt(3) / 2;
            P = obj.TransformMatrix(3, 2) * parameters.Edge / (2 * sqrt(3)) - obj.TransformMatrix(3, 4);

            q = M^2 + N^2;
            n = 2 * M * P;
            p = P^2 - N^2;

            obj.OmegaF = acosd(((-n + sqrt(n^2 - 4 * q * p)) / (2 * q)));
        end
    end
end
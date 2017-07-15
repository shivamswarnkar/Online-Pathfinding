%{
	Geom2d.m

	This class knows about 

		points, edges, polygons

	Moreover, we assume these are all mapshape objects!!!

	This class has ONLY static methods such as

		sep(obj, obj)
		leftOf( p1, p2, p3)

	ALL geometric computation should be done in this class.

	Please add other methods as the need arise.
%}

classdef Geom2d 

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static = true)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% returns the separation between obj1 and obj2
	%	You only need 2 cases:
	%	 (obj1,obj2) = (point, point)
	%	 (obj1,obj2) = (point, edge)
	function s = sep(point, obj)
		 if (isa(obj,'mapshape')) % obj is line
             PX = obj.X;
             PY = obj.Y;
             A = [PX(1) PY(1)];
             B = [PX(2) PY(2)];
             line = [PX(1) PY(1) PX(2) PY(2)];
             proj = Geom2d.project_point_to_line_segment(A,B, point);
             t = Geom2d.FindT(A,B,proj);
             if(t>1)
                 s = norm(point - B);
             elseif(t<0)
                 s = norm(point -A);
             else 
                 s= norm(point -proj);
             end
         else % obj is point
             s = norm(obj-point);
         end
    end
    
    function t = FindT(A, B, point)
        %point = A + t*(B-A);
        t = (point(1) - A(1)) / (B(1)-A(1));
    end
    
    function [q] = project_point_to_line_segment(A,B,p)
          AB = (B-A);
          AB_squared = dot(AB,AB);
          if(AB_squared == 0)
                q = A;
          else
                Ap = (p-A);
                t = dot(Ap,AB)/AB_squared;
            if (t < 0.0) 
                q = A;
            elseif (t > 1.0) 
                q = B;
            else
                q = A + t * AB;
            end
         end
    end
	% returns true iff (p1,p2,p3) represents a "Left Turn"
	%
	function bool = leftOf(p1, p2, p3)
		% fill!
    end
    function test()
        edge = mapshape([1 6], [0 0]);
        Q = [4 4];
        s = Geom2d.sep(Q, edge);
        disp(['answer should be four? ',num2str(s)]);
        
        edge = mapshape([1 5], [0 4]);
        Q = [0 0];
        s = Geom2d.sep(Q, edge);
        disp(['answer should be one? ',num2str(s)]);
        
        edge = mapshape([1 5], [0 4]);
        Q = [9 1];
        s = Geom2d.sep(Q, edge);
        disp(['answer should be five? ',num2str(s)]);
        
        edge = mapshape([1 5], [0 4]);
        Q = [5 0];
        s = Geom2d.sep(Q, edge);
        disp(['answer should be 4over root 2? ',num2str(s)]);
        
    end

    end
end





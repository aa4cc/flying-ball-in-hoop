// Import a library with models of metric nuts
include <cyl_head_bolt.scad>;

//----------------------------------------------------
// ------------ Parameters ------------ 
//----------------------------------------------------
R = 1.5; // radius of the o-ring core
r2 = 194/2; // inner radius of the hoop (from center of the hoop to the center of the o ring profile)
r3 = 84/2+R+1.5; // outter radius of the inner hoop 
h1 = 4; // height of the base of the hoop
h2 = 8; // distance from the base to the center of the o-ring profile
h3 = 14.7; // distance between the o-rings (center to center)
h4 = 2.5; //distance from the outter o-ring to the outter edge of the hoop
h_tot = h1+h2+h3+h4;
R_ext = 0.25;
r_r = 2.5; // depth of the rim
r1 = r2+2*R+2+5; // outter radius of the hoop

r_in = 27.5;

echo("Outter diameter of the hoop is: ", 2*r1);

d_nevim = 0.5;
h_nevim = 0.5;

d_rib = 16;

//d_tooth = 0.1231;
d_tooth = 0.25;

alpha = 55;
beta = 25;
gamma = 50;

// Calculate some values for a bit (not much actually) more clear calculations in the following script 
hx = h1+h2+R*sin(alpha);
dx = r1-r2-R*(1+cos(alpha));
hy = h2-(R+R_ext)*sin(beta);
dy = (R+R_ext)*cos(beta);

hz = r_r*tan(gamma);

r_groove = r1-dx-sqrt(d_nevim*d_nevim/2)+r_r; //thickness of the wall between the outter side of the large hoop and the bottom of the groove

part1_height = hx;
part2_height = 2*(h3/2+h2+h1-hx);
part3_height = h1+h2+h3+h4 - part1_height - part2_height;


//----------------------------------------------------
// ------------ Modelling ------------ 
//----------------------------------------------------
// outter o-rings
module outter_oring_lower() {
    translate([r2+R,h1+h2,0]){
        circle(R, $fn=50);
    };
};
module outter_oring_upper() {
    translate([0,h3,0]){
        outter_oring_lower();
    };
};

// Mounting holes
module mounting_hole_m3_tall(){
    cylinder(h=h1+h2+h3+h4+1, r=1.6, center=false,,$fn=50);
}
module mounting_hole_m3(){
    cylinder(h=h1+h2+h3+h4, r=1.6, center=false,,$fn=50);
}

// ------------ outter hoop (the larger one) ------------ 

//// Profiles of the parts of the outter hoop
// Profile 1 - the bottom one
//      before the subtraction of the o-rings
module profile_part01() {
    polygon(points=[[r2+R-dy,0],[r1,0],[r1,hx],[r1-dx,hx], [r2+R,h1+h2],[r2+R-dy,h1+hy],[r2+R-dy,h1]]);
};

// model of the tooth biting into the oring (parameter d_tooth)
module profile_part01_tooth() {
    polygon(points=[[r2+R-R*cos(beta),h1+h2-R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2-R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2-R],[r2+R-R*cos(beta),h1+h2-R]]);
}

//      after the subtraction of the o-ring
module profile_part1() {
    union() {
        difference() {
            profile_part01();
            outter_oring_lower();
        };
        profile_part01_tooth();
    }
};

// Profile 2 - the middle one
module profile_part2_half() {
    polygon(points=[[r1,hx], [r1-dx,hx], [r1-dx-sqrt(d_nevim*d_nevim/2),hx+sqrt(d_nevim*d_nevim/2)],[r1-dx-sqrt(d_nevim*d_nevim/2),hx+sqrt(d_nevim*d_nevim/2)+h_nevim], [r_groove, hx+sqrt(d_nevim*d_nevim/2)+h_nevim+hz],[r_groove, h1+h2+h3/2],[r1,h1+h2+h3/2]]);
};
module profile_part2() {
    union(){
        profile_part2_half();
        translate([0,2*(h1+h2+h3/2),0]) {
            mirror([0,1,0]){
                color("Cyan") profile_part2_half();
            };
        };
    };
};

// Profile 3 - the bottom one
//      before the subtraction of the o-rings
module profile_part03() {
    polygon(points=[[r1,h1+h2+h3-R*sin(alpha)],[r1-dx,h1+h2+h3-R*sin(alpha)], [r2+R,h1+h2+h3], [r2+R-dy,h1+h2+h3+(R+R_ext)*sin(beta)], [r2+R-dy,h1+h2+h3+h4], [r1,h1+h2+h3+h4]]);
};

// model of the tooth biting into the oring (parameter d_tooth)
module profile_part03_tooth() {
    polygon(points=[[r2+R-R*cos(beta),h1+h2+h3+R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2+h3+R*sin(beta)],[r2+R-R*cos(beta)+d_tooth,h1+h2+h3+R],[r2+R-R*cos(beta),h1+h2+h3+R]]);
}

//      after the subtraction of the o-ring
module profile_part3() {
    union() {
        difference() {
            profile_part03();
            outter_oring_upper();
        }
        profile_part03_tooth();
    }
};


//// Go to 3D
// Outter mounting holes
module outter_mounting_holes() {
    for (i=[1:6]) {
        rotate([0,0,i*60])
            translate([0,r1-(r1-r_groove)/2+0.3,0])
                mounting_hole_m3_tall();
    };
};

// Revolve the profiles and subtract the outter mounting holes
module part1(){
    union() {
        difference(){
            rotate_extrude($fn = 360){
                profile_part1();
            };
            outter_mounting_holes();
        };
        base();
    };
};

module part2(){
    difference(){
        rotate_extrude($fn = 360){
            profile_part2();
        };
        outter_mounting_holes();
    }
};

module part3(){
    difference(){
        rotate_extrude($fn = 360){
            profile_part3();
        };
        outter_mounting_holes();
    }
};

//// Test parts
module part1_test(revolve_angle){
    union() {
        difference(){
            rotate(90-revolve_angle/2) {
                rotate_extrude(angle=revolve_angle, $fn = 360){
                    profile_part1();
                };
            }
            outter_mounting_holes();
        };
    };
};

module part2_test(revolve_angle){
    difference(){
        rotate(90-revolve_angle/2) {
            rotate_extrude(angle=revolve_angle, $fn = 360){
                profile_part2();
            };
        }
        outter_mounting_holes();
    }
};

module part3_test(revolve_angle){
    difference(){
        rotate(90-revolve_angle/2) {
            rotate_extrude(angle=revolve_angle, $fn = 360){
                profile_part3();
            };
        }
        outter_mounting_holes();
    }
};

// ------------ The base ------------ 
// inner mounting holes
module inner_mounting_holes(){
    for (i=[1:6]) {
        rotate([0,0,i*60])
            translate([0,47/2,0]) {
                mounting_hole_m3();
                scale(1.05)
                    translate([0,0,2])
                        nut("M3");
            };
    }

    // Bldc mounting holes
    for (i=[1:4]) {
        rotate([0,0,i*90+45])
            translate([0, sqrt(2)*14.2/2,0])
                mounting_hole_m3();
    }
    cylinder(h=h1+1, r=5.5, center=false,,$fn=50);
}


module inner_circle_small() {
    cylinder(h=h1, r=r_in, center=false,,$fn=180);
}

module inner_circle_large() {
    cylinder(h=h1, r=r2+R-dy+1, center=false,,$fn=180);
}


// Ribs joining the outter hoop to the inner circle
// Model one rib
module bottom_planar_rib() {
    translate([r_in-d_rib,0,0]){
        square([d_rib,(r2+R-dy)],false);
    };
};

// copy and rotate it four times to get half of the total ribs
module bottom_planar_4ribs() {
    for (i=[1:4]) {
        rotate([0,0,i*90])
            bottom_planar_rib();
    }
};

// mirror the four ribs to get the remaining four
module bottom_8ribs(){
    bottom_planar_4ribs();
    mirror([1,0,0]){
        bottom_planar_4ribs();
    };
};

// extrude all the eight ribs and take the intersetion of the extruded ribs with the larger inner circle (full base)
module ribs() {
    intersection(){
        linear_extrude(height = h1) {
            bottom_8ribs();
        };
        inner_circle_large();
    };
};

// Model the base - take union of the ribs, inner circle and subtract the inner mounting holes
module base() {
    difference(){
        union(){
            ribs();
            inner_circle_small();
        }
        inner_mounting_holes();
    };
}

//----------------------------------------------------
// ------------ Inner hoop (in progress) ------------ 
//----------------------------------------------------
module profile_part01_inner() {
    translate([-r1+r2+r3,0,0])
        mirror([1,0,0])
            translate([-r1,0,0]) {
                difference(){
                    profile_part1();
                    polygon(points=[[r2+R-dy-0.1,-0.1],[r1+0.1,-0.1],[r1,h1],[r2+R-dy,h1]]);
                }
            }
};


module profile_part02_inner() {
    translate([-r1+r2+r3,0,0])
        mirror([1,0,0])
            translate([-r1,0,0]) {
                profile_part2();
            }
};

module profile_part03_inner() {
    translate([-r1+r2+r3,0,0])
        mirror([1,0,0])
            translate([-r1,0,0]) {
                profile_part3();
            }
};

//inner hoop mounting pillar
module inner_hoop_pillar(height) {
    translate([0,47/2,0]) {
        difference() {
            union() {
                translate([0,0,h1])
                    cylinder(h=height, r=3.2, center=false, $fn=50);
                translate([-3.2,0,h1])
                    cube([2*3.2,2*3.2+7,height], center=false);
            }
            mounting_hole_m3();
        }
    }
}

// inner mounting holes
module inner_hoop_pillars(height){
    for (i=[1:6]) {
        rotate([0,0,i*60])
            inner_hoop_pillar(height);
    }
}	

module inner_hoop_part1() {
	union() {
		rotate_extrude($fn = 200)
	            profile_part01_inner();
	    inner_hoop_pillars(hx-h1);
	}
}
module inner_hoop_part2() {
	union() {
		rotate_extrude($fn = 200)
		            profile_part02_inner();
		translate([0,0,hx-h1])
			inner_hoop_pillars(part2_height);
		}
}
module inner_hoop_part3() {
	union() {
		rotate_extrude($fn = 200)
		            profile_part03_inner();
		translate([0,0,hx-h1+part2_height])
			inner_hoop_pillars(part3_height);
	}
}

// ------------ Debug outputs ------------ 
//color("Cyan")
//rotate_extrude($fn = 50)
//            profile_part1();
//color("Blue")
//rotate_extrude($fn = 50)
//            profile_part2();
//color("Cyan")
//rotate_extrude($fn = 50)
//            profile_part3();
//
//color("Red"){
//    rotate_extrude($fn = 50)
//    {
//        outter_oring_lower();
//        outter_oring_upper();
//    }
//};
//
//base();

//union(){
//    part1();
//    part2();
//    part3();
//};

// profile_part01_inner();
// profile_part02_inner();
// profile_part03_inner();

// ------------ test parts ------------ 
//test_rev_angle = 15;
//part1_test(test_rev_angle);
//part2_test(test_rev_angle);
//part3_test(test_rev_angle);
            
// ------------ final outputs ------------ 
%part1();
%part2();
%part3();
%inner_hoop_part1();
%inner_hoop_part2();
%inner_hoop_part3();

//rotate([180,0,0])
//inner_hoop_part3();
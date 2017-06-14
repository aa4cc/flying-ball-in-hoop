w_board = 36; 
h_board = 53;
wall_thick = 1.8;
holding_rim_thick = 0.7;

module board_outline(d){
 polygon(points = [ [-d, -d], [w_board+d, -d], [w_board+d, h_board-7], [w_board-7, h_board+d], [7, h_board+d], [-d, h_board-7]]);
}

module zobacek(d, w, h) {
    translate([0,h,0])
    rotate([90,0,0])
        linear_extrude(h)
            polygon(points = [ [0, 0], [-d, 0], [-d, .5*d], [0, 1.5*d], [w, 1.5*d], [w, 0]]);
}


// Mounting holes
module mounting_hole_m3(){
    cylinder(h=10, r=1.6, center=false,,$fn=50);
}

module bldc_box() {
    translate([w_board+0.15, 19, 6.6])
        zobacek(0.7, wall_thick, 10);


    translate([-0.15, 19+10, 6.6])
    rotate([0,0,180])
        zobacek(0.7, wall_thick, 10);


    difference(){
        linear_extrude(6.6)
            board_outline(wall_thick);
        
        translate([0,0,1])
            linear_extrude(4)
            board_outline(-holding_rim_thick);
        translate([0,0,5])
            linear_extrude(1.6)
            board_outline(0.15);

        translate([-wall_thick,holding_rim_thick,2])
            linear_extrude(5)
                square([wall_thick+holding_rim_thick, 5]);
    }
}


translate([-17.5,0,26]){
rotate([180,0,0]) {
difference() {
linear_extrude(26){
    difference() {
         square([35, 55], center=true);
         // Bldc mounting holes
         for (i=[1:4]) {
             rotate([0,0,i*90])
                 translate([0, 25/2,0])
                     circle(1.6, $fn=50);
             rotate([0,0,i*90+45])
                 translate([0, 30/2,0])
                     circle(1.6, $fn=50);
         }
         
     }
     } 
 translate([0,-22,13])
    rotate([90,0,90])
        cylinder(h = 60, r=3.2, center = true, $fn=50);
 translate([0,22,13])
    rotate([90,0,90])
        cylinder(h = 60, r=3.2, center = true, $fn=50);
    cube([35,33,42], center=true);
 translate([14.5,0,0]){
        cube([6,55,42], center=true);
    }    
 }
}
}

translate([wall_thick,w_board/2,0])
    rotate([0,0,-90])
        bldc_box();
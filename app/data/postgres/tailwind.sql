-- disable this if you want to see things
drop schema public cascade;
create schema public;

create extension pgcrypto;

create table stores (
  id serial primary key,
  name text not null,
  owner text not null,
  address text not null,
  city text not null,
  state text not null,
  zip text not null,
  created_at timestamptz not null default now()
);


create table suppliers (
  id serial primary key,
  name text not null,
  contact_email text,
  ordering_endpoint text
);

create table collections (
  id serial primary key,
  slug text not null unique,
  name text not null,
  image text,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);



create table customers (
  id serial primary key,
  customer_key text not null default gen_random_uuid(),
  email text not null,
  order_count integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table delivery_methods (
  id serial primary key,
  sku text not null,
  name text not null,
  arrival_window text,
  minutes_from_now integer,
  fee numeric
);

create table product_types (
  id serial primary key,
  slug text not null unique,
  name text not null,
  description text,
  image text
);

create table products (
  id serial primary key,
  product_type_id integer not null references product_types(id),
  supplier_id integer not null references suppliers(id),
  sku text not null,
  name text not null,
  price decimal(10,2) default 0 not null,
  description text,
  image text,
  digital boolean default false not null,
  unit_description text,
  package_dimensions text,
  weight_in_pounds text,
  reorder_amount integer default 10 not null,
  status text default 'in-stock' not null,
  requires_shipping bool not null default true,
  warehouse_location text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table collections_products (
  id serial primary key,
  collection_id integer not null references collections(id),
  product_id integer not null references products(id)
);

create table cart_items(
	id serial primary key,
	session_id text not null,
	product_id int not null references products(id),
	quantity int not null default 1,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);


create table checkouts(
	number uuid not null primary key default gen_random_uuid(),
	total decimal(10,2) not null default 0,
	body jsonb not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table shipments (
  number uuid not null primary key default gen_random_uuid(),
  checkout_id uuid not null references checkouts(number),
  delivery_method_id integer not null references delivery_methods(id),
  status text default 'in-process'::text not null,
  tracking_number text,
  estimated_delivery text default 'Pending'::text not null,
  estimated_delivery_time timestamptz not null default now(),
  created_at timestamptz not null default now(),
  shipped_at timestamptz not null default now()
);

create table shipment_items(
	shipment_id uuid not null references shipments(number),
	sku text not null,
	name text not null,
	location text,
	weight int not null default 0,
	dimentions text
);

create table store_inventory (
  id serial not null primary key,
  product_id integer references products(id),
  store_id integer references stores(id),
  units_in_stock integer default 0 not null,
  units_on_order integer default 0 not null
);

create table supply_orders (
  id serial primary key,
  product_id integer,
  store_id integer references stores(id),
  supplier_id integer,
  units_ordered integer not null,
  status text default 'ordered' not null,
  created_at timestamptz not null default now()
);

-- STORES
insert into stores(name, owner, address, city, state, zip) values ('Tailwind Online', 'M. Sullivan', '1 Redmond Way', 'Redmond', 'WA', '00000');
insert into stores(name, owner, address, city, state, zip) values ('Redmond Town Center', 'Dee Yan', '12 City Center', 'Redmond', 'WA', '98123');

-- DELIVERY METHODS
insert into delivery_methods(sku, name, arrival_window, fee, minutes_from_now) values('bike', 'Tailwind Bike Messenger', '4-5 hours', 8, 300);
insert into delivery_methods(sku, name, arrival_window, fee, minutes_from_now) values('van', 'Tailwind Delivery Van', '1-3 hours', 5, 180);
insert into delivery_methods(sku, name, arrival_window, fee, minutes_from_now) values('drone', 'Premium Drone Service', '30-40 minutes', 12, 40);
insert into delivery_methods(sku, name, arrival_window, fee, minutes_from_now) values('in-store', 'In store pickup', 'right now', 0, 0);

-- SUPPLIERS
insert into suppliers(id, name, contact_email) values(1,'Northwind Traders','northwind@test.com');
insert into suppliers(id, name, contact_email) values(2,'Tailwind Wholesale','tailwind@test.com');
insert into suppliers(id, name, contact_email) values(3,'AdventureWorks','adworks@test.com');
insert into suppliers(id, name, contact_email) values(4,'Contoso','contoso@test.com');

-- PRODUCT TYPES
insert into product_types(id, name, slug) values(1,'Art Supplies', 'art-supplies');
insert into product_types(id, name, slug) values(2,'Gardening and Outdoors', 'garden-outdoors');
insert into product_types(id, name, slug) values(3,'Holidays and Gifts', 'holiday-gifts');
insert into product_types(id, name, slug) values(4,'Metalworking', 'metalwork');
insert into product_types(id, name, slug) values(5,'Tools and Hardware', 'tools-hardware');
insert into product_types(id, name, slug) values(6,'Snacks and Groceries', 'snacks-groceries');

-- PRODUCTS
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('brush_cleaner','Meltdown Brush Cleaner',1,2,'brush_cleaner.jpg',12.99,'1 - 10oz Jar','4x8x2',3.2,'Zone 1, Shelf 12, Slot 6',true, 'We all leave our brushes sitting around, full of old dry paint. Don''t worry! The Meltdown Brush Cleaner can remove just about anything.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('brush_case','Sticks In Here Brush Case',1,2,'brush_case.jpg',55.99,'1 folded case','3x8x2',1,'Zone 1, Shelf 12, Slot 2',true, 'Stop losing your paint brushes between your car seats or behind your couch - put them in this beautiful case made from the best fake leather you can find.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('brushes_made_from_stuff','Brushes Made from Weird Stuff',1,2,'brushes_made_from_stuff.jpg',25.99,'50 brushes','4x9x2',2,'Zone 1, Shelf 13, Slot 5',true, 'Most paint brushes are made form synthetic this and that making brush strokes look the same everywhere! Why not try our Brushes Made from Weird Stuff? We have turtle shell, dry grass and cat whisker brushes. See the difference!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('calligraphy_set','Bespoke Calligraphy Set',1,2,'calligraphy_set.jpg',189,'1 pen','2x5x1',0.3,'Zone 1, Shelf 4, Slot 2',true, 'Anyone can write, but not everyone has a *special* pen set like this one. Be the bespoke hipster that you are and write in cursive using this special calligraphy set.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('drafting_tools','Bespoke Drafting Set',1,2,'drafting_tools.jpg',45,'Tools and carrying case','5x10x3',1.2,'Zone 1, Shelf 4, Slot 1',true, 'Build your next bridge (or tunnel) using our Bespoke Drafting Set. Everyone drives across *regular* bridges everyday - but they''ll rememeber yours - because it''s _bespoke_.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('home_jewelry_kit','Blind Bat Home Jewelry Kit',1,2,'home_jewelry_kit.jpg',15,'Tools, buttons and wire','12x24x4',2.5,'Zone 1, Shelf 123 Slot 62',true, 'Don''t know what to do with your life? Try making jewelry! It''s the latest, easiest home-grown career path.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('home_ring_making_kit','Rings True Home Ring Making Kit',1,2,'home_ring_making_kit.jpg',22,'Tools, metal ingot and solder','13x22x4',2.6,'Zone 1, Shelf 3, Slot 36',true, 'Nothing says ''love'' more than a ring of your own making. Use any old metal - including old utensils and silverware! ');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('pack_unused_brushes','50 Random Unused Paint Brushes',1,2,'pack_unused_brushes.jpg',19.99,'50-75 brushes, wrapped','11x2x2',1,'Zone 1, Shelf 6, Slot 6',true, 'Why paint by the numbers when you can let the universe guide your hands? Just sit back and pull a brush from our Random Brush Pack - we''ll do the rest.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('pack_used_paint','Pack of Previously Used Paint',1,2,'pack_used_paint.jpg',6.99,'20-30 tubes of paint','18x12x4',4,'Zone 1, Shelf 22, Slot 9',true, 'Don''t you hate it when people come over see your easel and canvases sitting next to tubes _full of paint_. You don''t want to look like an artsy poseur do you? Our pack of used paint will make it look like you just washed up after staying up all night painting your masterpiece. When they ask where it is, just tell them ''it''s at the gallery, with the others.''');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('steelo_silver_pen','Steal This Steelo Silver Pen',1,2,'steelo_silver_pen.jpg',154.99,'1 pen','5x2x2',0.5,'Zone 1, Shelf 1, Slot 6',true, 'This artsy, nouveau pen fits right in your pocket to convey your hipster, artsy aesthetic. Matches most beard colors perfectly.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('steelo_pretty_pen','Steal This Steelo Wooden Pen',1,2,'steelo_pretty_pen.jpg',129.9,'1 pen','5x2x2',0.5,'Zone 1, Shelf 1, Slot 7',true, 'Do you love pencils but need to use a pen every now and again? Try our Steelo Wooden pen. It''s just like a pencil, but writes with ink!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('amazing_bug_zappers','Amazing-zing-zingy Bug Zapper',2,4,'amazing_bug_zappers.jpg',49.99,'Pack of 4 lights','12x12x4',4.2,'Zone 8, Shelf 1, Slot 1',true, 'We love nature, but when it bothers, stings or bites us, it needs to die. Our Amazing-zing-zingy Bug Zapper is quick and humane, eliminating those pests with a satisfying ZZZZZZAP!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('brooms','Sweeping Statement Broom',2,4,'brooms.jpg',35.99,'4 brooms','60x18x18',9,'Zone 8, Shelf 1, Slot 1',true, 'Catch all the dust and dirt in your home or garage with our Sweeping Statement Broom Set.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('gloves_and_shears','Green with Ivy Pruning Set',2,4,'gloves_and_shears.jpg',18.99,'Pair of gloves and shears','8x4x4',2,'Zone 8, Shelf 41, Slot 7',true, 'Our Green with Ivy shears cut through any vine or small branch with ease. Our canvas gloves will protect your green thumb as well!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('green_beans','Get Your Veggies! Green Beans',2,4,'green_beans.jpg',12.99,'Pack of beans for planting','4x4x8',2,'Zone 8, Shelf 1, Slot 25',true, 'Who doesn''t love green beans cooked up with some garlic, salt and butter! Also great for a snack when deep fried.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('lotus','Pack of 3 Pretty Lotus Flowers',2,4,'lotus.jpg',24.99,'4 lotus plants in single pots','36x24x4',18,'Zone 8, Shelf 1, Slot 32',true, 'No backyard pond (or random park water feature) is complete without a lotus and some lily pads. Our pack of 3 will ensure that your meditation time will be filled with beatiful color.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('narcissus','The Center of Attention Narcissus',2,4,'narcissus.jpg',19.99,'4 narcissus plants in single pots','36x24x4',18,'Zone 8, Shelf 1, Slot 28',true, 'The beautiful gaze of the narcissus can fill your morning with our Center of Attention Narcissus flower pack. Put them on your table to greet you first thing in the morning, making you feel like the world revolves around you, and only you.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('poinsettia','Holidays Year Round Poinsettia',2,4,'poinsettia.jpg',19.99,'1 plant in a pot','18x6x6',5,'Zone 8, Shelf 1, Slot 24',true, 'Enjoy the holiday season every day of the year with our Holidays Year Round Poinsettia. We hate waiting for the winter holidays too - so why wait! Put on your favorite holiday music and load up on the plants that make this seasone the best of the year.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('tulip_bulbs_100_pack','Holland''s Finest Tulips, 100 Pack',2,4,'tulip_bulbs_100_pack.jpg',49.99,'Bag of 12 bulbs','6x4x8',3,'Zone 8, Shelf 1, Slot 4',true, 'All flowers are beautiful, but there''s something special about Tulips. If you''ve ever been to Holland, you know what it feels like to have your breath taken away but fields and fields of endless tulips. Now you can do the same in your own backyard with our 100 pack of Holland''s Finest Tulips.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('cabin_in_woods','Deep Woods Escape Cabin',2,4,'cabin_in_woods.jpg',499.99,'Unassembled cabin with framing, braces and screws. No tools','92x48x38',285,'Zone 8, Shelf 83, Slot 1',true, 'Tired of living in this century? Escape to the back woods in your own backyard with our Deep Woods Escape Cabin. Put on an old straw hat, grab a pipe and a rocking chair and ease into 19th century quietude.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('cold_drink_warm_place','A Cold Drink in a Warm Place',3,3,'cold_drink_warm_place.jpg',899.99,'Digital pass','--',0,'--',false, 'Winter is wonderful, but it''s also long and cold. Escape the cold, dark, rainy gray weather and enjoy our Cold Drink in a Warm Place. This is a specia kind of gift: the kind that you give yourself. Choose 1 of 40 warm destinations around the world - we''ll have the cold drink waiting for you.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('gifts_when_you_forget','A Set of Gifts for When You Forget',3,3,'gifts_when_you_forget.jpg',99.99,'4 gifts, individually wrapped','24x24x8',18,'Zone 4, Shelf 85, Slot 2',true, 'We all forget those important birthdays or holiday events. Don''t get caught out - have a gift at the ready for when you forget about them, or just don''t have the time. ');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('holiday_cookies_assorted','Holiday Cookies, Sorted by Color',3,3,'holiday_cookies_assorted.jpg',12.99,'1 tin of assorted cookies','6x6x2',1,'Zone 4, Shelf 3, Slot 9',true, 'Everyone loves the holiday shortbread cookies from Tailwind. Make sure to grab a few boxes on your way out today!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('holiday_cookies_euro','Holiday Cookies from Europe',3,3,'holiday_cookies_euro.jpg',15.99,'1 tin of assorted cookies','6x6x2',1,'Zone 4, Shelf 3, Slot 10',true, 'Add some mystery to your holiday season with our assorted Holiday Cookies from Europe. Conversations abound with comments like ''what is this?'' and ''do I taste licorice?''.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('holiday_decoration_city_pack','City-scale Holiday Decoration Pack',3,3,'holiday_decoration_city_pack.jpg',1299.99,'6 large boxes of lights and decorations','124x124x93',485,'Zone 4, Shelf 12, Slot 6',true, 'Liven up your city this holiday season by decorating it top to bottom with lights from our City-scale Holiday Decoration pack. You can feel proud of your town as your friends drive through on their way to your holiday gathering!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('holiday_lights','Bespoke, Retro Holiday Lighting',3,3,'holiday_lights.jpg',36.99,'4 strands of lights, 12 lights apiece','18x6x4',2,'Zone 4, Shelf 7, Slot 5',true, 'Blinking lights and animated figures are fun, but nothing beats the nostalgic lighting from decades ago. Our Bespoke, Retro Holiday Lighting pack will let your neighbors know that you care for tradition.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('horse_duster','Mighty Dirty Horse Duster',3,3,'horse_duster.jpg',49.99,'1 bag of dust with application towel','18x4x3',5,'Zone 4, Shelf 4, Slot 3',true, 'Have a horse that you _want_ to ride but just don''t have the time? We understand. You can make it _look_ like you''re riding every day, however, with our Mighty Dirty Horse Duster. ');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('led_handpowered_light','Powered by Hand LED Light',3,3,'led_handpowered_light.jpg',16.99,'1 light','5x5x3',0.2,'Zone 4, Shelf 12, Slot 3',true, 'The latest advancements in science, literally at your fingertips! Using the natural galvanic response created by the heat of your hand and the salts in your sweat, *you* will power the Powered by Hand LED light.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('old_school_blog','Bespoke, Old School Blogging Platform',3,3,'old_school_blog.jpg',169.99,'A single bog','--',0,'--',false, 'Anyone can create a blog using Wordpress, Ghost, Jekyll or a thousand other platforms. Why not stand out? With our Bespoke Old School Blogging Platform you''ll get your point across one person at a time, just like it used to be.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('overkill_egg_sheller','The Overkill Series: Egg Sheller',3,3,'overkill_egg_sheller.jpg',69.99,'1 mallet','9x3x4',1.4,'Zone 4, Shelf 5 Slot 2',true, 'Shelling a hardboiled egg can be frustrating. The shell sticks to the white and everything comes apart. Now you can show that egg who''s boss with our Overkill Series Egg Sheller. With one, quick motion that shell will be all over the floor.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('overkill_nut_cracker','The Overkill Series: Nut Cracker',3,3,'overkill_nut_cracker.jpg',69.99,'1 mallet','9x3x4',1.4,'Zone 4, Shelf 5 Slot 3',true, 'Nut crackers take far too much effort and can hurt your hands. With our Overkill Nut Cracker, you can crush that nut with one single blow while working off a little stress.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('perfect_gift','The Perfect Gift',3,3,'perfect_gift.jpg',999.99,'1 gift','12x18x6',3,'Zone 4, Shelf 9, Slot 1',true, 'Some people love shopping, others loathe it. Rather than spend your entire day trying to find that perfect gift for your favorite someone, let us do it for you. Our Perfect Gift is guaranteed to delight even the pickiest of the picky.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('typewriter','Bespoke, Vintage Word Processing Application',3,3,'typewriter.jpg',89.99,'1 typewriter, with ribbon','12x12x8',3,'Zone 4, Shelf 6, Slot 2',true, 'Writing your thoughts and ideas using a modern word processing application can indeed be productive, but what does it say about you and your particular style? Our Bespoke Word Processing Application lets you show others how tasteful you are, in your own bespoke way.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('youbethejudge_decision_maker','The Decider',3,3,'youbethejudge_decision_maker.jpg',79.99,'1 mallet, with wooden pad','9x3x4',1.4,'Zone 4, Shelf 5 Slot 4',true, 'As a parent, you need to be sure your decisions are heard loud and clear. As a professional, it''s important for your thoughts to carry weight in a meeting. As a person, it''s time for others to pay attention! The You Be The Judge Decision Maker puts a firm exclamation point to any concept you''re trying to get across.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('55-pound-anvil','Lead Balloon 55-pound Anvil',4,2,'55-pound-anvil.jpg',69.99,'1 anvil','12x36x18',55,'Zone 1, Shelf 1, Slot 1',true, 'Our Lead Balloon 55-pound Anvil is the perfect base to use for your next smithing project. Made from solid iron ore, our anvil can be used for shaping fake weaponry for your next LARP event, or as a clever ruse to capture a fast bird.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('arc_welder','Northern Light Arc Welder',4,2,'arc_welder.jpg',499.99,'1 arc welder with 12 rods, preassembled','48x24x19',68,'Zone 1, Shelf 55, Slot 2',true, 'Bond different pieces of metal into any shape you can think of with our Northern Light Arc Welder. Channeling 100 volts of pure electricity into slabs of metal has never been more fun.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('blacksmithing_set','Bespoke Backyard Game Blacksmithing Set (without Anvil)',4,2,'blacksmithing_set.jpg',599.99,'1 anvil, 5 ingots pig iron, tools, submersion bucket, hammers','85x45x46',256,'Zone 1, Shelf 42, Slot 2',true, 'Nothing says summer fun quite playing a game of horse shoes in your own backyard while cooking steaks on the barbequeue. Unless, that is, you''re playing with your own bespoke horse shoes! Show off your blacksmithing skills with our Backyard Games Blacksmith set! You can create all kinds of fun toys, including horse shoes, lawn darts and medieval weaponry.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('hand_grinder','Bare Knuckles Hand Grinder',4,2,'hand_grinder.jpg',49.99,'1 hand grinder with 5 attachments and guard','12x8x5',4,'Zone 1, Shelf 8, Slot 16',true, 'Whether sharpening the blades of your skates or polishing your favorite cuirass for this weekend''s LARP event - our Bare Knuckle Hand Grinder is up to the task. Sharpen edges and polish things like a medieval boss.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('hand_sander','Bare Knuckles Hand Sander',5,2,'hand_sander.jpg',32.99,'1 hand grinder with 5 attachments and guard','12x8x5',4,'Zone 1, Shelf 8, Slot 15',true, 'For quick and easy sanding jobs there''s nothing better than Tailwind''s Bare Knuckle Hand Sander. Powered by a 12-volt motor and a dust bag, you''ll have those maple boards smooth and shiny in no time.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('homeowner_tools','The Right Tool for the Job: Apartment Pack',5,2,'homeowner_tools.jpg',129.99,'Set of tools including hammer, screwdrivers, wire cutters, needle nose, utility knife and assorted wrenches','18x18x3',4,'Zone 1, Shelf 22, Slot 2',true, 'Just move into your first apartment or condo? Maybe you''re downsizing and just want a simple set of tools? Our Right Tool for the Job Series Apartment Pack is the set for you. You''ll get a big hammer, some screw drivers, allen wrenches, a utility knife and more.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('large_excavator','The Right Tool for the Job: 8 yard Frontend Loader',5,2,'large_excavator.jpg',8999.99,'1 excavator, assembled. No fuel.','175x88x104',5300,'Zone 1, Shelf 99, Slot 1',true, 'Is your backyard taking too much time to keep up? Maybe your front yard has a few too many trees? Take care of it all in an hour with our 8-yard Frontend Loader. This monster will scrape off the top 6-inches of soil from any yard, leaving nothing but glorious dirt.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('planer','The Right Tool for the Job: Plane Old Planer',5,2,'planer.jpg',49.99,'1 planer','6x4x18',2,'Zone 1, Shelf 3, Slot 6',true, 'Strip away the grime and nasty bits from that old wood stock using our Plain Old Planer. Power planers are much too precise for bespoke work like yours, so do it by hand the way they did a century ago.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('power_leveller','The Right Tool for the Job: Power Leveller',5,2,'power_leveller.jpg',26.99,'1 bubble level','4x4x48',2,'Zone 1, Shelf 12, Slot 6',true, 'Take your picture-hanging skills to the next level with the Power Leveller from Tailwind Traders. With our unique ''fit the bubble in the thing'' levelling mechanism, a true level is virtually assured.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('ranch_tools','Bespoke Rancher Toolset, Faux Dust Finish',5,2,'ranch_tools.jpg',59.99,'Hammer, Ax, gloves and various leather items','36x12x12',8,'Zone 1, Shelf 22, Slot 3',true, 'The perfect accompanyment to any suburban home that''s far enough away from the city to be called a ''ranch'', our Bespoke Rancher Toolset tells all who see it that you, indeed, love life on the range. We know that getting out there is difficult, that''s why we''ve applied a stressed finish to each piece, putting you in the imaginary saddle.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('random_bolts','Pre-randomized Bolt Set',5,2,'random_bolts.jpg',23.99,'40-50 bolts, various sizes','8x8x4',4,'Zone 1, Shelf 15, Slot 3',true, 'Every house has a drawer full of random bits and bobs. For the do-it-yourselfers out there, these are often various screws and bolts. Is your random drawer empty? If so, fill it with our Pre-randomized Bolt Set and start loudly sifting through it, looking for that metric-sized bolt that you _know_ isn''t in there.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('wood_lathe','Going Going Gone! Bespoke Bat Maker',5,2,'wood_lathe.jpg',399.99,'1 lathe with 4 tools','89x75x54',350,'Zone 1, Shelf 23, Slot 1',true, 'Your friends might be OK using a Louisville Slugger or DeMarini at the corporate softball game, but not you - you''re no sheep! You prefer to make your own bespoke bat, hewn from the best maple money can buy. Now you can turn that perfect bat using our Going Going Gone! Bespoke Bat Maker, and turn some heads when you come up to bat. You''ll strike gold even when you''re striking out.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('woodworking_tools','The Right Tool for the Job: Woodworker''s Pack',5,2,'woodworking_tools.jpg',79.99,'Set of various clamps, stamps, and tools','24x12x8',9.5,'Zone 1, Shelf 42, Slot 3',true, 'Whether you''re new to woodworking or an old practiced hand, our all-in-one Woodworker''s Pack is the set that every woodworker needs. You''ll get various carving and turning tools, as well as clamps and pinchers.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('wrench_set','The Right Tool for the Job: Organized Wrench Set',5,2,'wrench_set.jpg',68.99,'25 standard and 25 metric wrenches','24x24x12',6,'Zone 1, Shelf 12, Slot 2',true, 'Tighten those bolts into oblivion with our Organized Wrench Set, which comes presorted so you don''t have to think about where each wrench goes.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('anniseed_syrup','Anniseed Syrup',6,1,'anniseed_syrup.jpg',5.99,'12 - 550 ml bottles','12x12x8',7,'Zone 1, Shelf 76, Slot 6',true, 'Want to make an impression at breakfast? Try our Anniseed syrup for your next family waffle adventure. Maple syrup is great, but Anniseed Syrup will generate a lively discussion!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('anton_cajun_seasoning','Chef Anton''s Cajun Seasoning',6,1,'anton_cajun_seasoning.jpg',6.99,'48 - 6 oz jars','24x24x8',3,'Zone 1, Shelf 76, Slot 4',true, 'Take home a few jars of Chef Anton''s Cajun Seasoning for your next batch of back bay bayou bouilliabaisse. Zesty and full of zip, Northwind''s flagship spice is now available at checkout.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('camembert','Camembert Pierrot',6,1,'camembert.jpg',11.99,'15 - 300 g rounds','36x36x5',8,'Cold Storage, Slot 2',true, 'Need an extra gift for a birthday or holiday party? Nothing says that you care more than a lively bit of cheese. Northwind''s Camembert Pierrot is an old favorite that''s sure to delight cheese lovers of all ages.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('chai','Chai',6,1,'chai.jpg',8.99,'10 boxes x 30 bags','18x18x6',4,'Zone 1, Shelf 76, Slot 3',true, 'This warm, spicy delight from Northwind will chase the chill away this holiday season. Share a chai with a friend and let the conversation flow.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('escargot','Escargots de Bourgogne',6,1,'escargot.jpg',15.99,'24 pieces','12x12x6',4,'Cold Storage, Slot 12',true, 'Tired of the same old taco night? Is spaghetti coming out of your ears? Try something different for the family dinner with Northwind''s Escargot de Bourgogne. Cooked up with a little butter, white wine and garlic or served sashimi style, these little guys are sure to delight everyone.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('gnocchi','Gnocchi di nonna Alice',6,1,'gnocchi.jpg',12.99,'24 - 250 g pkgs.','36x36x5',6,'Zone 12, Shelf 12, Slot 6',true, 'Not sure what to make for dinner tonight? Grab a pack of Gnocchi di nonna Alice on your way out of the store today. 4 meals in 4 minutes - everyone loves gnocchi!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('knackerbrod','Gustaf''s Knäckebröd',6,1,'knackerbrod.jpg',14.99,'24 - 500 g pkgs.','18x12x12',4,'Zone 12, Shelf 12, Slot 6',true, 'Northwind''s head chef, Gustaf Bugnion, created these wonderful flat crackers that go well with any cheese or spread. Great for dinner parties or lunch snacks, grab some on your way out today.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('lumberjack','Laughing Lumberjack Lager',6,1,'lumberjack.jpg',8.99,'24 - 12 oz bottles','24x12x12',12,'Cold Storage, Slot 55',true, 'I''m a lumberjack and I have beer! That''s the song we find ourselves singing after work when we hoist a pint of Northwind''s flagship lager. Refresh yourself after a long day in your workshop with a tall cold one!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('perth_pasties','Perth Pasties',6,1,'perth_pasties.jpg',24.99,'48 pieces','36x24z18',16,'Cold Storage, Slot 34',true, 'Ah the good old smells of home... in the Outback! Australia is known for a lot of things and food is definitely *not* one of them. Except for these delightful little pasties, full of tender goodness from our friends at Northwind. Perfect for a bit of lunch on a walkabout!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('rostbratwurst','Thüringer Rostbratwurst',6,1,'rostbratwurst.jpg',18.99,'50 bags x 30 sausgs.','36x36x12',28,'Cold Storage, Slot 93',true, 'Cold weather, cold beer and hot roasted brats - that sounds like the perfect way to cap off a weekend. Our brats are flown in from Munich, Germany, the home of Oktoberfest. Get yourself some kraut and mustard, an accodion and some oompah! Here comes the gemütlich!');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('sir_rodneys_scones','Sir Rodney''s Scones',6,1,'sir_rodneys_scones.jpg',16.99,'24 pkgs. x 4 pieces','36x36x12',16,'Cold Storage, Slot 43',true, 'Enjoy breakfast the european way with Sir Rodney''s Scones. Crisp, light and full of fresh-baked flavor. Start your morning right by picking up a pack of 4 at checkout.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('steeleye_stout','Steeleye Stout',6,1,'steeleye_stout.jpg',8.99,'24 - 12 oz bottles','24x12x12',12,'Cold Storage, Slot 25',true, 'Picture this: a fresh log just added to a nice warm fire. You''re sitting next to it with a great book and a freshly poured Steeleye Stout. What a great night! Grab yourself a 6-pack at checkout.');
insert into products(sku, name, product_type_id, supplier_id, image, price, unit_description,package_dimensions,weight_in_pounds, warehouse_location, requires_shipping, description) 
values('uncle_bobs_pears','Uncle Bob''s Organic Dried Pears',6,1,'uncle_bobs_pears.jpg',4.99,'12 - 1 lb pkgs.','24x24x12',12,'Cold Storage, Slot 19',true, 'No one grows fresher pears than Uncle Bob - but these aren''t for snacking! Nope - these are for the good stuff: fresh pear cider! Beer is good, but cider is _love_. All you need is a barrel, some bread yeast and two weeks in a cool spot and you''ve got a tasty beverage.');

-- COLLECTIONS
insert into collections(name, slug, description) values('Popular', 'popular', 'Popular Tailwind Products');
insert into collections(name, slug, description) values('Recommended', 'recommended', 'Recommended Tailwind Products');


insert into collections_products(collection_id, product_id) values(1, 10);
insert into collections_products(collection_id, product_id) values(1, 42);
insert into collections_products(collection_id, product_id) values(1, 3);
insert into collections_products(collection_id, product_id) values(2, 14);
insert into collections_products(collection_id, product_id) values(2, 16);
insert into collections_products(collection_id, product_id) values(2, 22);

-- INVENTORY
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(1, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(2, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(3, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(4, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(5, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(6, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(7, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(8, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(9, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(10, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(11, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(12, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(13, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(14, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(15, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(16, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(17, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(18, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(19, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(20, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(21, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(22, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(23, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(24, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(25, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(26, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(27, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(28, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(29, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(30, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(31, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(32, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(33, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(34, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(35, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(36, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(37, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(38, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(39, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(40, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(41, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(42, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(43, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(44, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(45, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(46, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(47, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(48, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(49, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(50, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(51, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(52, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(53, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(54, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(55, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(56, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(57, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(58, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(59, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(60, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(61, 1, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(1, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(2, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(3, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(4, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(5, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(6, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(7, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(8, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(9, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(10, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(11, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(12, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(13, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(14, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(15, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(16, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(17, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(18, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(19, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(20, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(21, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(22, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(23, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(24, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(25, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(26, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(27, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(28, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(29, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(30, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(31, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(32, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(33, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(34, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(35, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(36, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(37, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(38, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(39, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(40, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(41, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(42, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(43, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(44, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(45, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(46, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(47, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(48, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(49, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(50, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(51, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(52, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(53, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(54, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(55, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(56, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(57, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(58, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(59, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(60, 2, 10, 0);
insert into store_inventory(product_id, store_id, units_in_stock, units_on_order)values(61, 2, 10, 0);

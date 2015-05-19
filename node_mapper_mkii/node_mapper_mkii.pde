import java.util.Iterator;

PFont mono;

int NODE_SIZE = 60;
int NODE_HEADER_H;
int NODE_HEADER_W;
int DISPATCHER_W;
int DISPATCHER_H;
int DISPATCHER_Y = 150;

String DISPATCHER_ADDR = "http://127.0.0.1:8080/";
boolean dispatcher_online = false;
JSONObject node_list;

void setup()
{
  size(400, 600);
  NODE_HEADER_H = NODE_SIZE / 4;
  NODE_HEADER_W = NODE_SIZE;

  DISPATCHER_W = width - 40;
  DISPATCHER_H = NODE_SIZE / 2;

  mono = loadFont("mono.vlw");
  textFont(mono, 8);

  rectMode(CENTER);
  textAlign(CENTER, CENTER);
}


void draw()
{ 
  background(255);
  fill(255);
  rect(width / 2, 50, width - 200, 40);
  fill(0);
  text("MIDAS NODE MAPPER 2.0", width / 2, 50, width - 200, 40);
  line(width/2, 70, width/2 ,150);

  // Try to read the node list
  try
  {
    node_list = request_nodes(DISPATCHER_ADDR);
    dispatcher_online = true;
  } catch (Exception e)
  {
    dispatcher_online = false;
  }

  draw_dispatcher(150, "127.0.0.1:8080", dispatcher_online);
  Iterator names = node_list.keyIterator();
  int idx = 0;
  if (dispatcher_online)
  {
    while (names.hasNext())
    {
      String node_name = names.next().toString();
      JSONObject node_status =  node_list.getJSONObject(node_name);
      String node_info_addr = DISPATCHER_ADDR + node_name;
      //JSONObject node_info = request_node_info(node_info_addr);
      draw_node(50 + (NODE_SIZE + 10)*idx, 300, node_status, node_info_addr);
      idx++;
    }
  }
}


void draw_dispatcher(int y, String addr, boolean dispatcher_online)
{
  fill(255);
  rect(width / 2, y, DISPATCHER_W, DISPATCHER_H);
  if (dispatcher_online)
    fill(150, 255, 150);
  else
    fill(255, 150, 150);
  rect(width / 2, y - DISPATCHER_H/2 - NODE_HEADER_H/2, DISPATCHER_W, NODE_HEADER_H);

  fill(0);
  text("DISPATCHER" + "\n" + addr, width / 2, y, width - 22, NODE_SIZE / 2 - 2);
  text("ONLINE", width / 2,  y - DISPATCHER_H/2 - NODE_HEADER_H/2, DISPATCHER_W, NODE_HEADER_H);
}


JSONObject request_nodes(String addr)
{
  String[] request = loadStrings(addr + "status/nodes");
  return JSONObject.parse(join(request, "\n"));
}

JSONObject request_node_info(String addr)
{
  return JSONObject.parse(join(loadStrings(addr + "/status/info"), "\n"));
}

void draw_node(int x, int y, JSONObject node_status, String info_addr)
{
  // Unpack node information
  Boolean is_primary = false;
  String name = trim_string(node_status.getString("name"));
  String status = node_status.getString("status").toUpperCase();
  String addr = node_status.getString("address").replace("tcp://", "");
  JSONObject node_info = JSONObject.parse("{}");

  // Draw node
  stroke(0);
  fill(255);
  rect(x, y, NODE_SIZE, NODE_SIZE);
  // Draw status
  if (status.equals("ONLINE"))
  {
    fill(150, 255, 150, (frameCount%64)*4);
    node_info = request_node_info(info_addr);
    is_primary = node_info.getBoolean("primary_node");
  }
  else
  {
    is_primary = false;
    fill(255, 150, 150);
  }
  rect(x, y - NODE_SIZE/2 - NODE_HEADER_H/2, NODE_SIZE, NODE_HEADER_H);
  

  // Draw data source
  String data_state;
  if (is_primary && status.equals("ONLINE"))
  {
    draw_data_source(x, y + NODE_SIZE + NODE_HEADER_H*2, node_info);
    line(x, y + NODE_SIZE/2, x, y + NODE_SIZE);
    fill(180, 180, 180);
    data_state = "PRIMARY";
  } else if (!is_primary && status.equals("OFFLINE"))
  {
    fill(255, 150, 150);
    data_state = "UNAVAIL.";
  }
  else
  {
    fill(150, 150, 255);
    data_state = "SECONDARY";
  }

  rect(x, y + NODE_SIZE/2, NODE_SIZE, NODE_HEADER_H);
  
  // Add text
  fill(0);
  text(name.toUpperCase() + "\n\n" + addr, x, y, NODE_SIZE-4, NODE_SIZE-4);
  text(status, x, y - NODE_SIZE/2- NODE_HEADER_H/2, NODE_SIZE, NODE_HEADER_H);
  text(data_state, x, y + NODE_SIZE/2, NODE_SIZE-4, NODE_HEADER_H-4);

  // Draw connecting line
  line(x, y - NODE_SIZE/2 - NODE_HEADER_H, x, DISPATCHER_Y + DISPATCHER_H/2); 
}


void draw_data_source(int x, int y, JSONObject info)
{
  fill(255);
  rect(x, y, NODE_SIZE, NODE_SIZE);
  fill(0);
  textAlign(LEFT);
  String status_text = ("NCH:  " + info.getInt("channel_count") + "\n" + 
                        "FS:   " + info.getInt("sampling_rate") + "\n" + 
                        "SIZE: " + info.getInt("buffer_size"));  
  text(status_text, x, y, NODE_SIZE - 10, NODE_SIZE - 10);
  textAlign(CENTER, CENTER);
  
  if (info.getInt("buffer_full") == 0)
  {
    Float box_width = map(frameCount%256, 0, 255, 0, NODE_SIZE - 10);
    fill(255);
    rect(x, y + NODE_SIZE/2 - NODE_HEADER_H, NODE_SIZE - 10, NODE_HEADER_H);
    fill(100, 100, 255, 50);
    noStroke();
    rect(x, y + NODE_SIZE/2 - NODE_HEADER_H, box_width, NODE_HEADER_H);
    stroke(0);
    fill(0);
    text("ACQ.", x, y + NODE_SIZE/2 - NODE_HEADER_H, NODE_SIZE - 10, NODE_HEADER_H);
  }
  else
  {
    fill(255, 255, 100);
    rect(x, y + NODE_SIZE/2 - NODE_HEADER_H, NODE_SIZE-10, NODE_HEADER_H);
    fill(0);
    text("FULL!", x, y + NODE_SIZE/2 - NODE_HEADER_H, NODE_SIZE - 10, NODE_HEADER_H);

  }
}


String trim_string(String str)
{
  if (str.length() > 8)
    return str.substring(0, 9);
  else
    return str;
}

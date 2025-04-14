const blackDice = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4AkZCCkEMaz+6AAAAnBJREFUOMulk89rXFUYxz/n3jvz5k1mMklqY5KJQYUYbQwYhCz8A7oQXbkRBBddlYK4FVwIbty3EMGF4EKKG1FEF+rShbULcaUUF2JEbJO2aTJJJpn53Xvuuee4GEycUQTxLA/fB5/zfL/nwP9kk5OToet18s/vz8Ryufzk0tLSrLV2VCn1wDl3EXgHCB8n4Pv+13Nzc5+laZoAOOc6wE/AH/8mcPUDPLhHuH2PYHM/Y2sfeZQRfbrAaNbjxMoWcmt7H/h9YmLikyAIPrTWHgLeHgho7y/SvdsmuHWFo18t8smrX5Dt9ugkQyYmF2i/ssiNMxdIshRgrVar1WDbWjtUSimlVG9gBQDZfkpztc65H77g1c05VpYvcfjJl3jh7Hdsbq1yfWOLQT9COWsGxphOFEUcP378M631e8aYvwYCJk1J4oCNu49Ye/gnn7/1JoeLBWbffJ1hnDCXtWnPz7NULfHiyuTBDkZGRtBan7bWng/DMP+EgHOOOI4ZjUZweI7WsZNcvbFKBo41yuj5OeZ/+w1xLk+5XCYIAryDJwCCIMAYQxRFPZVqTafTEe/cx2fD51+hs9GmhNA7ucDNdpckHaKUwlqLtRZjzP9XAOCcwxiDCOPnTlE82qDRbrC+tsEgjej3Y5IkQURQSqG1HgO01h4wG2NI05Q0TQkih5t+inPffku+WEKLolQqUa/XKRQKKKXGvQgC37ZtW7TWb8dx/MwYYIwhSRJ6vR7WWoqFIkq5MUxrTalUolarUSwWcc6NAUpr7YnIXWPM9f+s0RhDHMf0+32MMTjnCMNwDM1ms2RZNj7+Fwlv92ayXpZOAAAAAElFTkSuQmCC'
const whiteDice = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4AkZCCkbooRF1QAAAVVJREFUaN7tmMENgzAMRZ9bpO6QA2vQOeiWdA06Rrogx3SBnjKATEpFSUjixCEYS7lEQrzzHxDCxrZtwzSP83vnR2wSi+9hK4UxDv5ZkVLONWmJ/neCj8fjW+EnyYn0KUfTNLqu+1Ee4nEcP44vy1KM49iXZbmaz+u6JgDruh4BLlaSDQDHcbosy7Zpmgb5TudxmBP3+GmafgC+QbY455g7ZeecM8ixG4bBNk0jAHe3syzLMa3XsCRJNgCL7/vHJnmep4wxO8/zNj0Cm+e5OJ1OC8B9D9k28aqqxPl8fs2+t+0Td/KrqrI1TRPGmMdlN+sS1lqhtX6MrpTSZVnOQgghKKVkEASL+JVSlFJCCMEQe7VG/D8RH/GJj/jER3ziEx/xiY/4xEf89pXRdkCl4MjlgkrBIQ4OlYLjVDhUCo5q4VApOP6FQ6XgMD9N8T9xH0IjLyYKSulQAAAAAElFTkSuQmCC'

const fs = require('fs');
const { createCanvas, loadImage } = require('canvas');

const createIcon = async (dataUrl, size, outputPath) => {
  const img = await loadImage(dataUrl);
  const canvas = createCanvas(size, size);
  const ctx = canvas.getContext('2d');
  
  // Draw background
  if (dataUrl === blackDice) {
    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, size, size);
  } else {
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, size, size);
  }
  
  // Draw image centered and scaled to fit
  const scale = Math.min(size / img.width, size / img.height) * 0.8;
  const x = (size - img.width * scale) / 2;
  const y = (size - img.height * scale) / 2;
  
  ctx.drawImage(img, x, y, img.width * scale, img.height * scale);
  
  // Save to file
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(outputPath, buffer);
  console.log();
};

// Create icons
const run = async () => {
  try {
    await createIcon(whiteDice, 20, './temp_icons/icon_20x20_iphone_notifications.png');
    await createIcon(blackDice, 40, './temp_icons/icon_40x40_ipad_notifications.png');
    console.log('Done!');
  } catch (err) {
    console.error('Error creating icons:', err);
  }
};

run();

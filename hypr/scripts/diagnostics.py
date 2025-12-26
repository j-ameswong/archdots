import psutil
import time
import datetime
import os
from rich.live import Live
from rich.panel import Panel
from rich.layout import Layout
from rich.table import Table
from rich.console import Group
from rich.progress import Progress, BarColumn, TextColumn
from rich.text import Text
from rich import box

# --- Helper Functions ---

def get_size(bytes, suffix="B"):
    """Scale bytes to its proper format"""
    factor = 1024
    for unit in ["", "K", "M", "G", "T", "P"]:
        if bytes < factor:
            return f"{bytes:.1f}{unit}{suffix}"
        bytes /= factor

def get_network_speed(last_rec, last_sent):
    """Calculate speed based on delta from last check"""
    net = psutil.net_io_counters()
    
    # Bytes received/sent since boot
    curr_rec = net.bytes_recv
    curr_sent = net.bytes_sent
    
    # Speed is difference / time (we assume approx 1s interval)
    # If this is the first run, speed is 0
    if last_rec == 0:
        return 0, 0, curr_rec, curr_sent

    speed_down = curr_rec - last_rec
    speed_up = curr_sent - last_sent
    
    return speed_down, speed_up, curr_rec, curr_sent

def get_cpu_temp():
    """Attempt to find CPU temperature"""
    try:
        temps = psutil.sensors_temperatures()
        # Common sensor names for CPU
        for name in ['coretemp', 'cpu_thermal', 'k10temp', 'zenpower']:
            if name in temps:
                return temps[name][0].current
        return None
    except:
        return None

def get_top_process():
    """Find the process using the most CPU"""
    try:
        # Fetch top process by CPU usage
        processes = sorted(
            psutil.process_iter(['name', 'cpu_percent']),
            key=lambda p: p.info['cpu_percent'],
            reverse=True
        )
        if processes:
            return processes[0].info['name'], processes[0].info['cpu_percent']
    except:
        pass
    return "Unknown", 0.0

# --- Layout Generators ---

def generate_header():
    """Top status bar with Uptime and Load Avg"""
    uptime = datetime.timedelta(seconds=int(time.time() - psutil.boot_time()))
    load_avg = os.getloadavg() # returns (1, 5, 15) min load
    
    grid = Table.grid(expand=True)
    grid.add_column(justify="left", ratio=1)
    grid.add_column(justify="right", ratio=1)
    
    grid.add_row(
        f"[b cyan]UP:[/b cyan] {str(uptime).split('.')[0]}", 
        f"[b red]LOAD:[/b red] {load_avg[0]:.2f} {load_avg[1]:.2f}"
    )
    return Panel(grid, style="on #1e1e2e", box=box.SIMPLE, padding=(0,1))

def generate_body(last_rec, last_sent):
    # Fetch Data
    cpu_pct = psutil.cpu_percent()
    ram = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    down, up, new_rec, new_sent = get_network_speed(last_rec, last_sent)
    temp = get_cpu_temp()
    top_proc_name, top_proc_cpu = get_top_process()

    # Create Main Table
    table = Table(show_header=False, box=None, expand=True, padding=(0, 1))
    table.add_column(ratio=1) # Charts
    table.add_column(ratio=1) # Stats

    # -- Helper to make a simple bar --
    def make_bar(color, value):
        p = Progress(
            BarColumn(bar_width=None, style=color),
            TextColumn(""), 
            expand=True
        )
        p.add_task("", total=100, completed=value)
        return p

    # -- Column 1: Progress Bars --
    progress_group = Group(
        Text(f"CPU Usage ({cpu_pct}%)", style="bold blue"),
        make_bar("blue", cpu_pct),
        
        Text(f"RAM ({ram.percent}%)", style="bold magenta"),
        make_bar("magenta", ram.percent),
        
        Text(f"Disk ({disk.percent}%)", style="bold green"),
        make_bar("green", disk.percent),
    )

    # -- Column 2: Numeric Data --
    stats_table = Table.grid(padding=(0, 2))
    stats_table.add_column(style="bold white")
    stats_table.add_column(style="cyan", justify="right")

    # Network
    stats_table.add_row("⬇ Down:", get_size(down) + "/s")
    stats_table.add_row("⬆ Up:", get_size(up) + "/s")
    stats_table.add_row("", "") # Spacer
    
    # Thermals
    if temp:
        stats_table.add_row("🌡 Temp:", f"{temp}°C")
    else:
        stats_table.add_row("🌡 Temp:", "N/A")
    
    stats_table.add_row("", "") # Spacer

    # Processes
    stats_table.add_row("⚡ Top:", f"{top_proc_name}")
    stats_table.add_row("   Use:", f"{top_proc_cpu}%")

    table.add_row(progress_group, stats_table)

    # Handle Network Interface Name safely
    try:
        net_name = list(psutil.net_if_addrs().keys())[0]
    except:
        net_name = "Unknown"

    main_panel = Panel(
        table, 
        title="[b white]DIAGNOSTICS[/]", 
        border_style="cyan",
        subtitle=f"[dim]Network: {net_name}[/]"
    )
    
    return Group(generate_header(), main_panel), new_rec, new_sent

# --- Main Loop ---

last_rec = 0
last_sent = 0

# Initial stabilization sleep for CPU calculation
psutil.cpu_percent() 

with Live(refresh_per_second=1) as live:
    while True:
        try:
            layout, last_rec, last_sent = generate_body(last_rec, last_sent)
            live.update(layout)
        except Exception as e:
            live.update(Panel(f"Error: {e}", title="Error"))
        time.sleep(1)

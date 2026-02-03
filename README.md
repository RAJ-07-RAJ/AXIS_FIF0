

# **AXI-Stream FIFO RTL**

## **Overview**

This repository contains a **basic AXI4-Stream FIFO RTL implementation** intended to demonstrate **data buffering** between an AXI-Stream source and sink using the standard **TVALID/TREADY handshake**.

The design focuses on **decoupling an upstream AXI-Stream master from a downstream AXI-Stream slave** by introducing a FIFO stage.
It is primarily intended for **learning, RTL walkthroughs, and interview discussions**, rather than production deployment.

⚠️ **Note:**
This is a **learning-oriented FIFO design** and does **not claim full AXI4-Stream compliance** (e.g., limited backpressure optimization and no simultaneous read/write handling).

---

## **Project Scope (Current State)**

**Included in this version:**

* AXI-Stream FIFO RTL
* Pointer-based FIFO control logic
* Direct AXI-Stream slave-side input
* Direct AXI-Stream master-side output
* Basic functional testbench

---

## **AXI-Stream Signals Used**

### **Slave Side (FIFO Input)**

| Signal              | Direction    | Description                |
| ------------------- | ------------ | -------------------------- |
| `s_axis_tdata[7:0]` | Slave → FIFO | Streaming input data       |
| `s_axis_tvalid`     | Slave → FIFO | Indicates valid input data |
| `s_axis_tready`     | FIFO → Slave | FIFO ready to accept data  |
| `s_axis_tkeep`      | Slave → FIFO | Byte qualifier             |
| `s_axis_tlast`      | Slave → FIFO | End-of-packet indicator    |

---

### **Master Side (FIFO Output)**

| Signal              | Direction     | Description                 |
| ------------------- | ------------- | --------------------------- |
| `m_axis_tdata[7:0]` | FIFO → Master | Streaming output data       |
| `m_axis_tvalid`     | FIFO → Master | Indicates valid output data |
| `m_axis_tready`     | Master → FIFO | Downstream ready signal     |
| `m_axis_tkeep`      | FIFO → Master | Byte qualifier              |
| `m_axis_tlast`      | FIFO → Master | End-of-packet indicator     |

---

## **Data Transfer Rule**

AXI-Stream data transfer occurs when:

```
TVALID == 1 and TREADY == 1
```

This condition is used internally to:

* Accept data into the FIFO (write operation)
* Release data from the FIFO (read operation)
* Track packet boundaries using `TLAST`

---

## **FIFO Architecture**

The FIFO internally stores:

* `TDATA`
* `TKEEP`
* `TLAST`

The design uses:

* Separate **write pointer** and **read pointer**
* A **count register** to track FIFO occupancy
* Full and empty detection based on the count value

### **Write Operation**

A FIFO write occurs when:

```
s_axis_tvalid == 1 && FIFO not full
```

---

### **Read Operation**

A FIFO read occurs when:

```
m_axis_tready == 1 && FIFO not empty
```

---

## **Module Description**

### **AXI-Stream FIFO (`axis_fifo`)**

* Acts as an AXI-Stream **slave** on the input side
* Acts as an AXI-Stream **master** on the output side
* Buffers streaming data internally
* Preserves packet boundaries using `TLAST`
* Provides basic backpressure through `TREADY`
* Designed for clarity and readability over performance

---

## **Verification**

### **Testbench (`axis_fifo_tb`)**

The testbench:

* Generates a free-running clock
* Applies active-low reset
* Pushes multiple data beats into the FIFO
* Applies backpressure by toggling `m_axis_tready`
* Observes correct data ordering and `TLAST` behavior

The testbench validates **basic functional correctness**, not full protocol corner cases.

---

## **Limitations / Known Gaps**

* No simultaneous read and write in the same cycle
* Simplified `TVALID` generation
* No skid buffer or output registering
* Not suitable for high-throughput AXI-Stream systems without enhancement

---

## **Intended Use**

* AXI-Stream FIFO learning
* Understanding handshake-based buffering
* RTL interview walkthroughs
* Reference design for enhanced FIFO implementations

---

## **Future Improvements**

* True AXI4-Stream compliant handshake behavior
* Support for concurrent read/write operations
* Parameterized data width and FIFO depth
* Assertions for protocol checking
* Coverage-driven verification

---


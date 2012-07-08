expect = chai.expect

describe "treeTable()", ->
  beforeEach ->
    @subject = $("<table><tr data-tt-id='0'><td>N0</td></tr><tr data-tt-id='1' data-tt-parent-id='0'><td>N1</td></tr></table>")

  it "maintains chainability", ->
    expect(@subject.treeTable()).to.equal(@subject)

  it "adds treeTable object to element", ->
    expect(@subject.data("treeTable")).to.be.undefined
    @subject.treeTable()
    expect(@subject.data("treeTable")).to.be.defined

  it "adds .treeTable css class to element", ->
    expect(@subject).to.not.have.class("treeTable")
    @subject.treeTable()
    expect(@subject).to.have.class("treeTable")

  describe "#destroy()", ->
    it "removes treeTable object from element", ->
      @subject.treeTable()
      expect(@subject.data("treeTable")).to.be.defined
      @subject.treeTable("destroy")
      expect(@subject.data("treeTable")).to.be.undefined

    it "removes .treeTable css class from element", ->
      @subject.treeTable()
      expect(@subject).to.have.class("treeTable")
      @subject.treeTable("destroy")
      expect(@subject).to.not.have.class("treeTable")

  # describe "with expandable: false"

  describe "with expandable: true", ->
    beforeEach ->
      @subject.treeTable(expandable: true)

    describe "for nodes with children", ->
      it "renders a clickable node toggler", ->
        expect(@subject.treeTable("node", 0).row).to.have("a")

    describe "for nodes without children", ->
      it "does not render a clickable node toggler", ->
        expect(@subject.treeTable("node", 1).row).to.not.have("a")

  describe "#node()", ->
    beforeEach ->
      @subject.treeTable()

    it "returns node by id", ->
      expect(@subject.treeTable("node", "0")).to.equal(@subject.data("treeTable").tree[0])
      expect(@subject.treeTable("node", 0)).to.equal(@subject.data("treeTable").tree[0])

    it "returns undefined for unknown node", ->
      expect(@subject.treeTable("node", "unknown")).to.be.undefined

describe "TreeTable.Node", ->

  describe "#ancestors()", ->
    beforeEach ->
      @subject = $("<table id='subject'><tr data-tt-id='1'></tr><tr data-tt-id='2' data-tt-parent-id='1'></tr><tr data-tt-id='3' data-tt-parent-id='2'></tr><tr data-tt-id='4' data-tt-parent-id='3'></tr></table>").treeTable().data("treeTable").tree

    it "has correct size", ->
      expect(_.size @subject[4].ancestors()).to.equal(3)

    it "includes the parent node", ->
      expect(@subject[4].ancestors()).to.include(@subject[4].parentNode())

    it "includes the parent's parent node", ->
      expect(@subject[4].ancestors()).to.include(@subject[3].parentNode())

    it "includes the root node", ->
      expect(@subject[4].ancestors()).to.include(@subject[1])

    it "does not include node itself", ->
      expect(@subject[4].ancestors()).to.not.include(@subject[4])

  describe "#children()", ->
    beforeEach ->
      @subject = $("<table id='subject'><tr data-tt-id='1'></tr><tr data-tt-id='2' data-tt-parent-id='1'></tr><tr data-tt-id='3' data-tt-parent-id='2'><tr data-tt-id='5' data-tt-parent-id='2'></tr></tr><tr data-tt-id='4' data-tt-parent-id='3'></tr></table>").treeTable().data("treeTable").tree

    it "includes direct children", ->
      expect(_.size @subject[2].children()).to.equal(2)
      expect(@subject[2].children()).to.include(@subject[3])
      expect(@subject[2].children()).to.include(@subject[5])

    it "does not include grandchildren", ->
      expect(@subject[2].children()).to.not.include(@subject[4])

    it "does not include parent", ->
      expect(@subject[2].children()).to.not.include(@subject[2].parentNode())

    it "does not include node itself", ->
      expect(@subject[2].children()).to.not.include(@subject[2])

  describe "#collapse()", ->
    beforeEach ->
      @table = $("<table id='subject'><tr data-tt-id='0'><td>N0</td></tr><tr data-tt-id='1' data-tt-parent-id='0'><td>N1</td></tr><tr data-tt-id='2' data-tt-parent-id='0'><td>N2</td></tr><tr data-tt-id='3' data-tt-parent-id='2'><td>N3</td></tr></table>").appendTo("body").treeTable(initialState: "expanded")
      @subject = @table.data("treeTable").tree

    afterEach ->
      @table.remove()

    it "hides children", ->
      expect(@subject[1].row).to.be.visible
      expect(@subject[2].row).to.be.visible
      @subject[0].collapse()
      expect(@subject[1].row).to.be.hidden
      expect(@subject[2].row).to.be.hidden

    it "recursively hides grandchildren", ->
      expect(@subject[3].row).to.be.visible
      @subject[0].collapse()
      expect(@subject[3].row).to.be.hidden

    it "maintains chainability", ->
      expect(@subject[0].collapse()).to.equal(@subject[0])

  describe "#expand()", ->
    beforeEach ->
      @table = $("<table><tr data-tt-id='0'><td>N0</td></tr><tr data-tt-id='1' data-tt-parent-id='0'><td>N1</td></tr><tr data-tt-id='2' data-tt-parent-id='0'><td>N2</td></tr><tr data-tt-id='3' data-tt-parent-id='2'><td>N3</td></tr></table>").appendTo("body").treeTable()
      @subject = @table.data("treeTable").tree

    afterEach ->
      @table.remove()

    it "shows children", ->
      expect(@subject[1].row).to.be.hidden
      expect(@subject[2].row).to.be.hidden
      @subject[0].expand()
      expect(@subject[1].row).to.be.visible
      expect(@subject[2].row).to.be.visible

    it "does not recursively show collapsed grandchildren", ->
      sinon.stub(@subject[2], "expanded").returns(false)
      expect(@subject[3].row).to.be.hidden
      @subject[0].expand()
      expect(@subject[3].row).to.be.hidden

    it "recursively shows expanded grandchildren", ->
      sinon.stub(@subject[2], "expanded").returns(true)
      expect(@subject[3].row).to.be.hidden
      @subject[0].expand()
      expect(@subject[3].row).to.be.visible

    it "maintains chainability", ->
      expect(@subject[0].expand()).to.equal(@subject[0])

  describe "#expanded()", ->
    beforeEach ->
      @subject = $("<table><tr data-tt-id='0'><td>Node</td></tr></table>").treeTable().data("treeTable").tree[0]

    it "returns true when expanded", ->
      @subject.expand()
      expect(@subject.expanded()).to.be.true

    it "returns false when collapsed", ->
      @subject.collapse()
      expect(@subject.expanded()).to.be.false

  describe "#expander", ->
    beforeEach ->
      @subject = $("<table><tr data-tt-id='0'><td>Node</td></tr></table>").treeTable().data("treeTable").tree[0]

    it "is a span", ->
      expect(@subject.expander).to.match("span")

    it "has the 'expander' class", ->
      expect(@subject.expander).to.have.class("expander")

    describe "when root node", ->
      beforeEach ->
        sinon.stub(@subject, "level").returns(0)

      it "is not indented", ->
        @subject.render()
        expect(@subject.expander.css("padding-left")).to.equal("0px")

    describe "when level 1 node", ->
      beforeEach ->
        sinon.stub(@subject, "level").returns(1)
        @subject.render()

      it "is indented", ->
        expect(@subject.expander.css("padding-left")).to.equal("19px")

    describe "and expandable: true", ->
      beforeEach ->
        @subject.settings = { expandable: true }

      it "has the 'branch' class", ->
        @subject.render()
        expect(@subject.expander).to.have.class("branch")

  describe "#hide()", ->
    beforeEach ->
      @table = $("<table><tr data-tt-id='0'><td>N0</td></tr><tr data-tt-id='1' data-tt-parent-id='0'><td>N1</td></tr></table>").appendTo("body").treeTable()
      @subject = @table.data("treeTable").tree
      @subject[0].expand()

    afterEach ->
      @table.remove()

    it "hides table row", ->
      expect(@subject[0].row).to.be.visible
      @subject[0].hide()
      expect(@subject[0].row).to.be.hidden

    it "recursively hides children", ->
      expect(@subject[1].row).to.be.visible
      @subject[0].hide()
      expect(@subject[1].row).to.be.hidden

    it "maintains chainability", ->
      expect(@subject[0].hide()).to.equal(@subject[0])

  describe "#id", ->
    it "is extracted from row attributes", ->
      subject = $("<table><tr data-tt-id='42'></tr></table>").appendTo("body").treeTable().data("treeTable").tree[42]
      expect(subject.id).to.equal(42)

  describe "#level()", ->
    beforeEach ->
      @subject = $("<table id='subject'><tr data-tt-id='1'></tr><tr data-tt-id='2' data-tt-parent-id='1'></tr><tr data-tt-id='3' data-tt-parent-id='2'></tr><tr data-tt-id='4' data-tt-parent-id='3'></tr></table>").treeTable().data("treeTable").tree

    it "equals the number of ancestors", ->
      expect(@subject[1].level()).to.equal(0)
      expect(@subject[2].level()).to.equal(1)
      expect(@subject[3].level()).to.equal(2)
      expect(@subject[4].level()).to.equal(3)

  describe "#parentId", ->
    it "is extracted from row attributes", ->
      subject = $("<table><tr data-tt-id='42' data-tt-parent-id='12'></td></tr></table>").treeTable().data("treeTable").tree[42]
      expect(subject.parentId).to.equal(12)

    it "is undefined when not available", ->
      subject = $("<table><tr data-tt-id='0'></td></tr></table>").treeTable().data("treeTable").tree[0]
      expect(subject.parentId).to.be.undefined

  describe "#parentNode()", ->
    beforeEach ->
      @subject = $("<table id='subject'><tr data-tt-id='0'></tr><tr data-tt-id='1' data-tt-parent-id='0'></tr></table>").treeTable().data("treeTable").tree

    describe "when node has a parent", ->
      beforeEach ->
        @subject = @subject[1]

      it "is a node object", ->
        expect(@subject.parentNode()).to.be.an.instanceof(TreeTable.Node)

      it "'s id equals this node's parentId", ->
        expect(@subject.parentNode().id).to.equal(@subject.parentId)

    describe "when node has no parent", ->
      beforeEach ->
        @subject = @subject[0]

      it "is null", ->
        expect(@subject.parentNode()).to.be.null

  describe "#show()", ->
    beforeEach ->
      @table = $("<table><tr data-tt-id='0'><td>N0</td></tr><tr data-tt-id='1' data-tt-parent-id='0'><td>N1</td></tr></table>").appendTo("body").treeTable()
      @subject = @table.data("treeTable").tree
      @subject[0].hide()

    afterEach ->
      @table.remove()

    it "shows table row", ->
      expect(@subject[0].row).to.be.hidden
      @subject[0].show()
      expect(@subject[0].row).to.be.visible

    it "maintains chainability", ->
      expect(@subject[0].show()).to.equal(@subject[0])

    describe "when expanded", ->
      beforeEach ->
        @subject[0].expand().hide()

      it "recursively shows children", ->
        expect(@subject[1].row).to.be.hidden
        @subject[0].show()
        expect(@subject[1].row).to.be.visible

    describe "when collapsed", ->
      beforeEach ->
        @subject[0].collapse().hide()

      it "does not show children", ->
        expect(@subject[1].row).to.be.hidden
        @subject[0].show()
        expect(@subject[1].row).to.be.hidden


  describe "#toggle()", ->
    beforeEach ->
      @table = $("<table><tr data-tt-id='42'><td>N42</td></tr><tr data-tt-id='24' data-tt-parent-id='42'><td>N24</td></tr></table>").appendTo("body").treeTable()
      @subject = @table.data("treeTable").tree

    afterEach ->
      @table.remove()

    it "toggles child rows", ->
      expect(@subject[24].row).to.be.hidden
      @subject[42].toggle()
      expect(@subject[24].row).to.be.visible
      @subject[42].toggle()
      expect(@subject[24].row).to.be.hidden

    it "maintains chainability", ->
      expect(@subject[42].toggle()).to.equal(@subject[42])

  describe "#treeCell", ->
    describe "with default column setting", ->
      beforeEach ->
        @subject = $("<table><tr data-tt-id='0'><th>Not part of tree</th><td>Column 1</td><td>Column 2</td></tr>").treeTable().data("treeTable").tree[0].treeCell

      it "is an object", ->
        expect(@subject).to.be.an("object")

      it "maps to a td", ->
        expect(@subject).to.be("td")

      it "maps to the first column by default", ->
        expect(@subject).to.contain("Column 1")

      it "contains an expander", ->
        expect(@subject).to.have("span.expander")

    describe "with custom column setting", ->
      beforeEach ->
        @subject = $("<table><tr data-tt-id='0'><th>Not part of tree</th><td>Column 1</td><td>Column 2</td></tr>").treeTable(column: 1).data("treeTable").tree[0].treeCell

      it "is configurable", ->
        expect(@subject).to.contain("Column 2")

describe "TreeTable.Tree", ->
  describe "#load()", ->
    it "maintains chainability", ->
      subject = new TreeTable.Tree($("<table></table>"))
      expect(subject.load()).to.equal(subject)

    describe "a table without rows", ->
      it "'s tree cache is empty", ->
        subject = new TreeTable.Tree($("<table></table>")).load().tree
        expect(_.size subject).to.equal(0)

    describe "a table with tree rows", ->
      it "caches all tree nodes", ->
        subject = $("<table><tr data-tt-id='0'></tr><tr data-tt-id='1' data-tt-parent-id='0'></tr></table>").treeTable().data("treeTable").tree
        expect(_.size subject).to.equal(2)
        expect(_.keys subject).to.include('0')
        expect(_.keys subject).to.include('1')

    describe "a table without tree rows", ->
      it "results in an empty node cache", ->
        subject = $("<table><tr></tr><tr></tr></table>").treeTable().data("treeTable").tree
        expect(_.size subject).to.equal(0)

    describe "a table with both tree rows and non tree rows", ->
      it "only caches tree nodes", ->
        subject = $("<table><tr></tr><tr data-tt-id='21'></tr></table>").treeTable().data("treeTable").tree
        expect(_.size subject).to.equal(1)
        expect(_.keys subject).to.include('21')

  describe "#render()", ->
    it "maintains chainability", ->
      subject = new TreeTable.Tree($("<table></table>"))
      expect(subject.render()).to.equal(subject)

  describe "#roots()", ->
    describe "when no rows", ->
      it "is empty", ->
        subject = $("<table></table>").treeTable().data("treeTable")
        expect(_.size subject.roots()).to.equal(0)

    describe "when single root node", ->
      beforeEach ->
        @subject = $("<table><tr data-tt-id='1'></tr><tr data-tt-id='2' data-tt-parent-id='1'></tr></table>").treeTable().data("treeTable")

      it "includes root node when only one root node exists", ->
        roots = @subject.roots()
        expect(_.size roots).to.equal(1)
        expect(roots).to.include(@subject.tree[1])

      it "does not include non-root nodes", ->
        expect(@subject.roots()).to.not.include(@subject.tree[2])

    describe "when multiple root nodes", ->
      beforeEach ->
        @subject = $("<table><tr data-tt-id='1'></tr><tr data-tt-id='2' data-tt-parent-id='1'></tr><tr data-tt-id='3'></tr></table>").treeTable().data("treeTable")

      it "includes all root nodes", ->
        roots = @subject.roots()
        expect(_.size roots).to.equal(2)
        expect(roots).to.include(@subject.tree[1])
        expect(roots).to.include(@subject.tree[3])

      it "does not include non-root nodes", ->
        expect(@subject.roots()).to.not.include(@subject.tree[2])

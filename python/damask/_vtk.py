import os
import multiprocessing as mp
from pathlib import Path
from typing import Union, Literal, List, Sequence

import numpy as np
import vtk
from vtk.util.numpy_support import numpy_to_vtk            as np_to_vtk
from vtk.util.numpy_support import numpy_to_vtkIdTypeArray as np_to_vtkIdTypeArray
from vtk.util.numpy_support import vtk_to_numpy            as vtk_to_np

from ._typehints import FloatSequence, IntSequence
from . import util
from . import Table
from . import Colormap


class VTK:
    """
    Spatial visualization (and potentially manipulation).

    High-level interface to VTK.
    """

    def __init__(self,
                 vtk_data: vtk.vtkDataSet):
        """
        New spatial visualization.

        Parameters
        ----------
        vtk_data : subclass of vtk.vtkDataSet
            Description of geometry and topology, optionally with attached data.
            Valid types are vtk.vtkImageData, vtk.vtkUnstructuredGrid,
            vtk.vtkPolyData, and vtk.vtkRectilinearGrid.

        """
        self.vtk_data = vtk_data


    def __repr__(self) -> str:
        """Give short human-readable summary."""
        info = [self.vtk_data.__vtkname__]

        for data in ['Cell Data', 'Point Data']:
            if data == 'Cell Data':  info.append(f'\n# cells: {self.N_cells}')
            if data == 'Point Data': info.append(f'\n# points: {self.N_points}')
            if data in self.labels:
                info += [f'  - {l}' for l in self.labels[data]]

        return util.srepr(info)


    def __eq__(self,
               other: object) -> bool:
        """
        Equal to other.

        Parameters
        ----------
        other : damask.VTK
            VTK to check for equality.

        """
        if not isinstance(other, VTK):
            return NotImplemented
        return self.as_ASCII() == other.as_ASCII()



    def copy(self):
        if   isinstance(self.vtk_data,vtk.vtkImageData):
            dup = vtk.vtkImageData()
        elif isinstance(self.vtk_data,vtk.vtkUnstructuredGrid):
            dup = vtk.vtkUnstructuredGrid()
        elif isinstance(self.vtk_data,vtk.vtkPolyData):
            dup = vtk.vtkPolyData()
        elif isinstance(self.vtk_data,vtk.vtkRectilinearGrid):
            dup = vtk.vtkRectilinearGrid()
        else:
            raise TypeError

        dup.DeepCopy(self.vtk_data)

        return VTK(dup)


    @property
    def comments(self) -> List[str]:
        """Return the comments."""
        field_data = self.vtk_data.GetFieldData()
        for a in range(field_data.GetNumberOfArrays()):
            if field_data.GetArrayName(a) == 'comments':
                comments = field_data.GetAbstractArray(a)
                return [comments.GetValue(i) for i in range(comments.GetNumberOfValues())]
        return []

    @comments.setter
    def comments(self,
                 comments: Union[str, Sequence[str]]):
        """
        Set comments.

        Parameters
        ----------
        comments : str or sequence of str
            Comments.

        """
        s = vtk.vtkStringArray()
        s.SetName('comments')
        for c in util.tail_repack(comments,self.comments):
            s.InsertNextValue(c)
        self.vtk_data.GetFieldData().AddArray(s)


    @property
    def N_points(self) -> int:
        """Number of points in vtkdata."""
        return self.vtk_data.GetNumberOfPoints()


    @property
    def N_cells(self) -> int:
        """Number of cells in vtkdata."""
        return self.vtk_data.GetNumberOfCells()


    @property
    def labels(self):
        """Labels of datasets."""
        labels = {}

        cell_data = self.vtk_data.GetCellData()
        if c := [cell_data.GetArrayName(a) for a in range(cell_data.GetNumberOfArrays())]:
            labels['Cell Data'] = c

        point_data = self.vtk_data.GetPointData()
        if p := [point_data.GetArrayName(a) for a in range(point_data.GetNumberOfArrays())]:
            labels['Point Data'] = p

        return labels


    @staticmethod
    def from_image_data(cells: IntSequence,
                        size: FloatSequence,
                        origin: FloatSequence = np.zeros(3)) -> 'VTK':
        """
        Create VTK of type vtk.vtkImageData.

        This is the common type for grid solver results.

        Parameters
        ----------
        cells : sequence of int, len (3)
            Number of cells along each dimension.
        size : sequence of float, len (3)
            Physical length along each dimension.
        origin : sequence of float, len (3), optional
            Coordinates of grid origin.

        Returns
        -------
        new : damask.VTK
            VTK-based geometry without nodal or cell data.

        """
        vtk_data = vtk.vtkImageData()
        vtk_data.SetDimensions(*(np.array(cells)+1))
        vtk_data.SetOrigin(*(np.array(origin)))
        vtk_data.SetSpacing(*(np.array(size)/np.array(cells)))

        return VTK(vtk_data)


    @staticmethod
    def from_unstructured_grid(nodes: np.ndarray,
                               connectivity: np.ndarray,
                               cell_type: str) -> 'VTK':
        """
        Create VTK of type vtk.vtkUnstructuredGrid.

        This is the common type for mesh solver results.

        Parameters
        ----------
        nodes : numpy.ndarray, shape (:,3)
            Spatial position of the nodes.
        connectivity : numpy.ndarray of np.dtype = int
            Cell connectivity (0-based), first dimension determines #Cells,
            second dimension determines #Nodes/Cell.
        cell_type : str
            Name of the vtk.vtkCell subclass. Tested for TRIANGLE, QUAD, TETRA, and HEXAHEDRON.

        Returns
        -------
        new : damask.VTK
            VTK-based geometry without nodal or cell data.

        """
        vtk_nodes = vtk.vtkPoints()
        vtk_nodes.SetData(np_to_vtk(np.ascontiguousarray(nodes)))
        cells = vtk.vtkCellArray()
        cells.SetNumberOfCells(connectivity.shape[0])
        T = np.concatenate((np.ones((connectivity.shape[0],1),dtype=np.int64)*connectivity.shape[1],
                            connectivity),axis=1).ravel()
        cells.SetCells(connectivity.shape[0],np_to_vtkIdTypeArray(T,deep=True))

        vtk_data = vtk.vtkUnstructuredGrid()
        vtk_data.SetPoints(vtk_nodes)
        cell_types = {'TRIANGLE':vtk.VTK_TRIANGLE, 'QUAD':vtk.VTK_QUAD,
                      'TETRA'   :vtk.VTK_TETRA,    'HEXAHEDRON':vtk.VTK_HEXAHEDRON}
        vtk_data.SetCells(cell_types[cell_type.split("_",1)[-1].upper()],cells)

        return VTK(vtk_data)


    @staticmethod
    def from_poly_data(points: np.ndarray) -> 'VTK':
        """
        Create VTK of type vtk.polyData.

        This is the common type for point-wise data.

        Parameters
        ----------
        points : numpy.ndarray, shape (:,3)
            Spatial position of the points.

        Returns
        -------
        new : damask.VTK
            VTK-based geometry without nodal or cell data.

        """
        N = points.shape[0]
        vtk_points = vtk.vtkPoints()
        vtk_points.SetData(np_to_vtk(np.ascontiguousarray(points)))

        vtk_cells = vtk.vtkCellArray()
        vtk_cells.SetNumberOfCells(N)
        vtk_cells.SetCells(N,np_to_vtkIdTypeArray(np.stack((np.ones  (N,dtype=np.int64),
                                                            np.arange(N,dtype=np.int64)),axis=1).ravel(),deep=True))

        vtk_data = vtk.vtkPolyData()
        vtk_data.SetPoints(vtk_points)
        vtk_data.SetVerts(vtk_cells)

        return VTK(vtk_data)


    @staticmethod
    def from_rectilinear_grid(grid: FloatSequence) -> 'VTK':
        """
        Create VTK of type vtk.vtkRectilinearGrid.

        Parameters
        ----------
        grid : sequence of sequences of floats, len (3)
            Grid coordinates along x, y, and z directions.

        Returns
        -------
        new : damask.VTK
            VTK-based geometry without nodal or cell data.

        """
        vtk_data = vtk.vtkRectilinearGrid()
        vtk_data.SetDimensions(*map(len,grid))
        coord = [np_to_vtk(np.array(grid[i]),deep=True) for i in [0,1,2]]
        [coord[i].SetName(n) for i,n in enumerate(['x','y','z'])]
        vtk_data.SetXCoordinates(coord[0])
        vtk_data.SetYCoordinates(coord[1])
        vtk_data.SetZCoordinates(coord[2])

        return VTK(vtk_data)


    @staticmethod
    def load(fname: Union[str, Path],
             dataset_type: Literal['ImageData', 'UnstructuredGrid', 'PolyData', 'RectilinearGrid'] = None) -> 'VTK':
        """
        Load from VTK file.

        Parameters
        ----------
        fname : str or pathlib.Path
            Filename for reading.
            Valid extensions are .vti, .vtu, .vtp, .vtr, and .vtk.
        dataset_type : {'ImageData', 'UnstructuredGrid', 'PolyData', 'RectilinearGrid'}, optional
            Name of the vtk.vtkDataSet subclass when opening a .vtk file.

        Returns
        -------
        loaded : damask.VTK
            VTK-based geometry from file.

        """
        if not Path(fname).expanduser().is_file():                                                  # vtk has a strange error handling
            raise FileNotFoundError(f'file "{fname}" not found')
        if (ext := Path(fname).suffix) == '.vtk' or dataset_type is not None:
            reader = vtk.vtkGenericDataObjectReader()
            reader.SetFileName(str(Path(fname).expanduser()))
            if dataset_type is None:
                raise TypeError('dataset type for *.vtk file not given')
            elif dataset_type.lower().endswith(('imagedata','image_data')):
                reader.Update()
                vtk_data = reader.GetStructuredPointsOutput()
            elif dataset_type.lower().endswith(('unstructuredgrid','unstructured_grid')):
                reader.Update()
                vtk_data = reader.GetUnstructuredGridOutput()
            elif dataset_type.lower().endswith(('polydata','poly_data')):
                reader.Update()
                vtk_data = reader.GetPolyDataOutput()
            elif dataset_type.lower().endswith(('rectilineargrid','rectilinear_grid')):
                reader.Update()
                vtk_data = reader.GetRectilinearGridOutput()
            else:
                raise TypeError(f'unknown dataset type "{dataset_type}" for vtk file')
        else:
            if   ext == '.vti':
                reader = vtk.vtkXMLImageDataReader()
            elif ext == '.vtu':
                reader = vtk.vtkXMLUnstructuredGridReader()
            elif ext == '.vtp':
                reader = vtk.vtkXMLPolyDataReader()
            elif ext == '.vtr':
                reader = vtk.vtkXMLRectilinearGridReader()
            else:
                raise TypeError(f'unknown file extension "{ext}"')

            reader.SetFileName(str(Path(fname).expanduser()))
            reader.Update()
            vtk_data = reader.GetOutput()

        return VTK(vtk_data)


    @staticmethod
    def _write(writer):
        """Wrapper for parallel writing."""
        writer.Write()


    def as_ASCII(self) -> str:
        """ASCII representation of the VTK data."""
        writer = vtk.vtkDataSetWriter()
        writer.SetHeader(f'# {util.execution_stamp("VTK")}')
        writer.WriteToOutputStringOn()
        writer.SetInputData(self.vtk_data)
        writer.Write()
        return writer.GetOutputString()


    def save(self,
             fname: Union[str, Path],
             parallel: bool = True,
             compress: bool = True):
        """
        Save as VTK file.

        Parameters
        ----------
        fname : str or pathlib.Path
            Filename for writing.
        parallel : bool, optional
            Write data in parallel background process. Defaults to True.
        compress : bool, optional
            Compress with zlib algorithm. Defaults to True.

        """
        if   isinstance(self.vtk_data,vtk.vtkImageData):
            writer = vtk.vtkXMLImageDataWriter()
        elif isinstance(self.vtk_data,vtk.vtkUnstructuredGrid):
            writer = vtk.vtkXMLUnstructuredGridWriter()
        elif isinstance(self.vtk_data,vtk.vtkPolyData):
            writer = vtk.vtkXMLPolyDataWriter()
        elif isinstance(self.vtk_data,vtk.vtkRectilinearGrid):
            writer = vtk.vtkXMLRectilinearGridWriter()

        default_ext = '.'+writer.GetDefaultFileExtension()
        ext = Path(fname).suffix
        writer.SetFileName(str(Path(fname).expanduser())+(default_ext if default_ext != ext else ''))

        if compress:
            writer.SetCompressorTypeToZLib()
        else:
            writer.SetCompressorTypeToNone()
        writer.SetDataModeToBinary()
        writer.SetInputData(self.vtk_data)

        if parallel:
            try:
                mp_writer = mp.Process(target=self._write,args=(writer,))
                mp_writer.start()
            except TypeError:
                writer.Write()
        else:
            writer.Write()


    # Check https://blog.kitware.com/ghost-and-blanking-visibility-changes/ for missing data
    def set(self,
            label: str = None,
            data: Union[np.ndarray, np.ma.MaskedArray] = None,
            info: str = None,
            *,
            table: 'Table' = None):
        """
        Add new or replace existing point or cell data.

        Data can either be a numpy.array, which requires a corresponding label,
        or a damask.Table.

        Parameters
        ----------
        label : str, optional
            Label of data array.
        data : numpy.ndarray or numpy.ma.MaskedArray, optional
            Data to add or replace. First array dimension needs to match either
            number of cells or number of points.
        info : str, optional
            Human-readable information about the data.
        table: damask.Table, optional
            Data to add or replace. Each table label is individually considered.
            Number of rows needs to match either number of cells or number of points.

        Notes
        -----
        If the number of cells equals the number of points, the data is added to both.

        """

        def _add_array(vtk_data,
                       label: str,
                       data: np.ndarray):

            N_p,N_c = vtk_data.GetNumberOfPoints(),vtk_data.GetNumberOfCells()
            if (N_data := data.shape[0]) not in [N_p,N_c]:
                raise ValueError(f'data count mismatch ({N_data} ≠ {N_p} & {N_c})')

            data_ = data.reshape(N_data,-1) \
                        .astype(np.single if data.dtype in [np.double,np.longdouble] else data.dtype)

            if data.dtype.type is np.str_:
                d = vtk.vtkStringArray()
                for s in np.squeeze(data_):
                    d.InsertNextValue(s)
            else:
                d = np_to_vtk(data_,deep=True)

            d.SetName(label)

            if N_data == N_p:
                vtk_data.GetPointData().AddArray(d)
            if N_data == N_c:
                vtk_data.GetCellData().AddArray(d)

        if data is None and table is None:
            raise KeyError('no data given')
        if data is not None and table is not None:
            raise KeyError('cannot use both, data and table')

        dup = self.copy()
        if isinstance(data,np.ndarray):
            if label is not None:
                _add_array(dup.vtk_data,
                           label,
                           np.where(data.mask,data.fill_value,data) if isinstance(data,np.ma.MaskedArray) else data)
                if info is not None: dup.comments += f'{label}: {info}'
            else:
                raise ValueError('no label defined for data')
        elif isinstance(table,Table):
            for l in table.labels:
                _add_array(dup.vtk_data,l,table.get(l))
                if info is not None: dup.comments += f'{l}: {info}'
        else:
            raise TypeError


        return dup


    def get(self,
            label: str) -> np.ndarray:
        """
        Get either cell or point data.

        Cell data takes precedence over point data, i.e. this
        function assumes that labels are unique among cell and
        point data.

        Parameters
        ----------
        label : str
            Data label.

        Returns
        -------
        data : numpy.ndarray
            Data stored under the given label.

        """
        cell_data = self.vtk_data.GetCellData()
        for a in range(cell_data.GetNumberOfArrays()):
            if cell_data.GetArrayName(a) == label:
                try:
                    return vtk_to_np(cell_data.GetArray(a))
                except AttributeError:
                    vtk_array = cell_data.GetAbstractArray(a)                                       # string array

        point_data = self.vtk_data.GetPointData()
        for a in range(point_data.GetNumberOfArrays()):
            if point_data.GetArrayName(a) == label:
                try:
                    return vtk_to_np(point_data.GetArray(a))
                except AttributeError:
                    vtk_array = point_data.GetAbstractArray(a)                                      # string array

        try:
            # string array
            return np.array([vtk_array.GetValue(i) for i in range(vtk_array.GetNumberOfValues())]).astype(str)
        except UnboundLocalError:
            raise KeyError(f'array "{label}" not found')


    def show(self,
             label: str = None,
             colormap: Union[Colormap, str] = 'cividis'):
        """
        Render.

        Parameters
        ----------
        label : str, optional
            Label of the dataset to show.
        colormap : damask.Colormap or str, optional
            Colormap for visualization of dataset. Defaults to 'cividis'.

        Notes
        -----
            See http://compilatrix.com/article/vtk-1 for further ideas.

        """
        try:
            import wx
            _ = wx.App(False)                                                                       # noqa
            width, height = wx.GetDisplaySize()
        except ImportError:
            try:
                import tkinter
                tk = tkinter.Tk()
                width  = tk.winfo_screenwidth()
                height = tk.winfo_screenheight()
                tk.destroy()
            except Exception:
                width  = 1024
                height =  768

        lut = vtk.vtkLookupTable()
        colormap_ = Colormap.from_predefined(colormap) if isinstance(colormap,str) else \
                    colormap
        lut.SetNumberOfTableValues(len(colormap_.colors))
        for i,c in enumerate(colormap_.colors):
            lut.SetTableValue(i,c if len(c)==4 else np.append(c,1.0))
        lut.Build()

        self.vtk_data.GetCellData().SetActiveScalars(label)
        mapper = vtk.vtkDataSetMapper()
        mapper.SetInputData(self.vtk_data)
        mapper.SetLookupTable(lut)
        mapper.SetScalarRange(self.vtk_data.GetScalarRange())

        actor = vtk.vtkActor()
        actor.SetMapper(mapper)
        actor.GetProperty().SetColor(230/255,150/255,68/255)

        ren = vtk.vtkRenderer()
        ren.AddActor(actor)
        if label is None:
            ren.SetBackground(67/255,128/255,208/255)
        else:
            colormap_vtk = vtk.vtkScalarBarActor()
            colormap_vtk.SetLookupTable(lut)
            colormap_vtk.SetTitle(label)
            colormap_vtk.SetMaximumWidthInPixels(width//100)
            ren.AddActor2D(colormap_vtk)
            ren.SetBackground(0.3,0.3,0.3)

        window = vtk.vtkRenderWindow()
        window.AddRenderer(ren)
        window.SetSize(width,height)
        window.SetWindowName(util.execution_stamp('VTK','show'))

        iren = vtk.vtkRenderWindowInteractor()
        iren.SetRenderWindow(window)
        if os.name == 'posix' and 'DISPLAY' not in os.environ:
            print('Found no rendering device')
        else:
            window.Render()
            iren.Start()
